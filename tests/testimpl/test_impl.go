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

// TestComposableComplete verifies the deployed AppConfig hosted configuration version and exercises create/delete version writes.
func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	client, applicationID, profileID := verifyHostedConfigurationVersion(t, ctx)
	exerciseHostedConfigurationVersionWrite(t, client, applicationID, profileID)
}

// TestComposableCompleteReadOnly verifies the deployed AppConfig hosted configuration version using read-only AWS API calls.
func TestComposableCompleteReadOnly(t *testing.T, ctx types.TestContext) {
	verifyHostedConfigurationVersion(t, ctx)
}

func verifyHostedConfigurationVersion(t *testing.T, ctx types.TestContext) (*appconfig.Client, string, string) {
	opts := ctx.TerratestTerraformOptions()
	region := terraform.Output(t, opts, "region")
	applicationID := terraform.Output(t, opts, "application_id")
	configurationProfileID := terraform.Output(t, opts, "configuration_profile_id")
	contentType := terraform.Output(t, opts, "content_type")
	versionNumber := int32Output(t, ctx, "version_number")
	expectedKMSKeyARN := terraform.Output(t, opts, "expected_kms_key_arn")
	expectedContent := terraform.Output(t, opts, "expected_content")

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
	assert.Equal(t, expectedKMSKeyARN, aws.ToString(version.KmsKeyArn))
	assert.JSONEq(t, expectedContent, string(version.Content))

	return client, applicationID, configurationProfileID
}

func exerciseHostedConfigurationVersionWrite(t *testing.T, client *appconfig.Client, applicationID string, profileID string) {
	t.Helper()

	created, err := client.CreateHostedConfigurationVersion(context.Background(), &appconfig.CreateHostedConfigurationVersionInput{
		ApplicationId:          aws.String(applicationID),
		ConfigurationProfileId: aws.String(profileID),
		Content:                []byte(`{"version":"1","flags":{"functional":{"name":"functional"}},"values":{"functional":{"enabled":true}}}`),
		ContentType:            aws.String("application/json"),
		Description:            aws.String("Functional test hosted configuration version."),
	})
	require.NoError(t, err)

	_, err = client.DeleteHostedConfigurationVersion(context.Background(), &appconfig.DeleteHostedConfigurationVersionInput{
		ApplicationId:          aws.String(applicationID),
		ConfigurationProfileId: aws.String(profileID),
		VersionNumber:          aws.Int32(created.VersionNumber),
	})
	require.NoError(t, err)
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
