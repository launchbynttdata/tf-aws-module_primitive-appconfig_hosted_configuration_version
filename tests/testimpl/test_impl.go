package testimpl

import (
	"context"
	"strconv"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/appconfig"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestComposableComplete verifies the deployed AppConfig hosted configuration version.
func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	verifyHostedConfigurationVersion(t, ctx)
}

// TestComposableCompleteReadOnly verifies the deployed AppConfig hosted configuration version using read-only AWS API calls.
func TestComposableCompleteReadOnly(t *testing.T, ctx types.TestContext) {
	verifyHostedConfigurationVersion(t, ctx)
}

func verifyHostedConfigurationVersion(t *testing.T, ctx types.TestContext) {
	opts := ctx.TerratestTerraformOptions()
	region := terraform.Output(t, opts, "region")
	applicationID := terraform.Output(t, opts, "application_id")
	configurationProfileID := terraform.Output(t, opts, "configuration_profile_id")
	contentType := terraform.Output(t, opts, "content_type")
	versionNumber := int32Output(t, ctx, "version_number")

	require.NotEqual(t, int32(0), versionNumber)
	assert.Equal(t, terraform.Output(t, opts, "expected_content_type"), contentType)

	client := appConfigClient(t, region)
	version, err := client.GetHostedConfigurationVersion(context.Background(), &appconfig.GetHostedConfigurationVersionInput{
		ApplicationId:          aws.String(applicationID),
		ConfigurationProfileId: aws.String(configurationProfileID),
		VersionNumber:          aws.Int32(versionNumber),
	})
	require.NoError(t, err)

	assert.Equal(t, applicationID, aws.ToString(version.ApplicationId))
	assert.Equal(t, configurationProfileID, aws.ToString(version.ConfigurationProfileId))
	assert.Equal(t, contentType, aws.ToString(version.ContentType))
	assert.Equal(t, versionNumber, version.VersionNumber)
	require.NotEqual(t, 0, len(version.Content))
}

func appConfigClient(t *testing.T, region string) *appconfig.Client {
	t.Helper()

	cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(region))
	require.NoError(t, err)

	return appconfig.NewFromConfig(cfg)
}

func int32Output(t *testing.T, ctx types.TestContext, name string) int32 {
	t.Helper()

	value, err := strconv.ParseInt(terraform.Output(t, ctx.TerratestTerraformOptions(), name), 10, 32)
	require.NoError(t, err)

	return int32(value)
}
