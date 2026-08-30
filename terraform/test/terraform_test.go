package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestVpcModule validates the VPC terraform module via Terratest
func TestVpcModule(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/vpc",

		Vars: map[string]interface{}{
			"project_name":             "8byte-test",
			"environment":              "test",
			"vpc_cidr":                 "10.0.0.0/16",
			"availability_zones":       []string{"ap-south-1a", "ap-south-1b"},
			"public_subnet_cidrs":      []string{"10.0.1.0/24", "10.0.2.0/24"},
			"private_app_subnet_cidrs": []string{"10.0.11.0/24", "10.0.12.0/24"},
			"private_db_subnet_cidrs":  []string{"10.0.21.0/24", "10.0.22.0/24"},
		},
	})

	// Run terraform init and terraform validate / plan check
	terraform.InitAndValidate(t, terraformOptions)
}

// TestSecurityModule validates the security terraform module via Terratest
func TestSecurityModule(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/security",

		Vars: map[string]interface{}{
			"project_name": "8byte-test",
			"environment":  "test",
			"vpc_id":        "vpc-1234567890abcdef0",
		},
	})

	terraform.InitAndValidate(t, terraformOptions)
}

// TestRootModuleValidation runs syntax and configuration validation on the root terraform module
func TestRootModuleValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
	})

	output := terraform.InitAndValidate(t, terraformOptions)
	assert.Contains(t, output, "Success! The configuration is valid.")
}
