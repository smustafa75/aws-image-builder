resource "aws_imagebuilder_image_recipe" "Recipe_01" {

  name         = "WindowsServer2019"
  parent_image = data.aws_ami.windows_2019.id
  working_directory= "C:\\"
  block_device_mapping {
    device_name = "/dev/sda1"
    no_device = false
    ebs {
      delete_on_termination ="true"
      encrypted = "true"
      volume_size = 50
      volume_type = "gp3"
      kms_key_id = var.kms_key_ebs

    }
  }

  version      = "1.0.0"


#Powershell
component {
    component_arn = "arn:aws:imagebuilder:${var.region_info}:aws:component/powershell-windows/x.x.x"
  }

#Cloudwatch
component {
    component_arn = "arn:aws:imagebuilder:${var.region_info}:aws:component/amazon-cloudwatch-agent-windows/x.x.x"
  }

#Kinesis
component {
    component_arn = "arn:aws:imagebuilder:${var.region_info}:aws:component/amazon-kinesis-agent-windows/x.x.x"
  }

#Kinesis_config
component {
    component_arn =  aws_imagebuilder_component.kinesis_config.arn
   
  }

#AWSCLI
component {
    component_arn =  aws_imagebuilder_component.aws_cli.arn
   
  } 
#WindowsUpdate
component {
    component_arn =  aws_imagebuilder_component.update_os.arn
   
  }

#Newrelic
component {
    component_arn =  aws_imagebuilder_component.newrelic_install.arn
   
  }


  }


#upload software package

resource "aws_s3_object" "awscli"{
  bucket = var.asset_bucket
  key = "AWSCLIV2.msi"
  source = "${path.module}/../installers/placeholder.txt"
  etag = filemd5("${path.module}/../installers/placeholder.txt")
  tags = var.tags
}


resource "aws_s3_object" "kinesis_config"{
  bucket = var.asset_bucket
  key = "appsettings.json"
  source = "${path.module}/../installers/placeholder.txt"
  etag = filemd5("${path.module}/../installers/placeholder.txt")
  tags = var.tags
}

resource "aws_s3_object" "newrelic_app"{
  bucket = var.asset_bucket
  key = "newrelic-infra.msi"
  source = "${path.module}/../installers/placeholder.txt"
  etag = filemd5("${path.module}/../installers/placeholder.txt")
  tags = var.tags
}

resource "aws_imagebuilder_image_pipeline" "Pipeline_x" {
  image_recipe_arn                 = aws_imagebuilder_image_recipe.Recipe_01.arn
 infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.Config_01.arn
  name                             = "W2K19Pipeline"
  distribution_configuration_arn =aws_imagebuilder_distribution_configuration.W2K19_distro.arn

  image_tests_configuration {
    image_tests_enabled ="true"
    timeout_minutes = 720
  }

  schedule {
    schedule_expression = "cron(0 0 1 * ? *)"  # Run monthly on the 1st at midnight
    pipeline_execution_start_condition = "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE"
  }
}

resource "aws_imagebuilder_image_pipeline" "Pipeline_02" {
  image_recipe_arn                 = aws_imagebuilder_image_recipe.Recipe_01.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.Config_02.arn
  name                             = "W2K19Pipelines"
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.W2K19_distro.arn

  image_tests_configuration {
    image_tests_enabled = "true"
    timeout_minutes = 720
  }

  schedule {
    schedule_expression = "cron(0 0 15 * ? *)"  # Run monthly on the 15th at midnight
    pipeline_execution_start_condition = "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE"
  }
}
resource "aws_imagebuilder_infrastructure_configuration" "Config_01" {
  name                          = "W2K19Config"
  description                   = "Primary configuration for Windows Server 2019 image building"
  instance_profile_name         = var.inst_profile
  instance_types                = ["t3.large"]
  security_group_ids            = var.sec_grp
  subnet_id                     = var.subnet_id
  terminate_instance_on_failure = false
  
  logging {
    s3_logs {
      s3_bucket_name = var.logging_bucket
      s3_key_prefix  = "logs"
    }
  }
  
  tags = var.tags
}


resource "aws_imagebuilder_infrastructure_configuration" "Config_02" {
  name                          = "W2K19Config02"
  description                   = "Secondary configuration for Windows Server 2019 image building"
  instance_profile_name         = var.inst_profile
  instance_types                = ["t3.large"]
  key_pair                      = "img-bldr-key"
  security_group_ids            = var.sec_grp
  subnet_id                     = var.p_subnet_id
  terminate_instance_on_failure = false
  
  logging {
    s3_logs {
      s3_bucket_name = var.logging_bucket
      s3_key_prefix  = "logs"
    }
  }
  
  tags = var.tags
}
resource "aws_imagebuilder_distribution_configuration" "W2K19_distro" {
  name = "w2k19distribution"
  
  distribution {
    region = var.region_info
    ami_distribution_configuration {
      name = "WindowsServer2019-{{ imagebuilder:buildDate }}"
      # Uncomment and add your target account IDs for cross-account distribution
      # target_account_ids = ["123456789012", "098765432109"]
      
      # Configure AMI sharing settings
      ami_tags = {
        Name        = "WindowsServer2019-Golden-AMI"
        Environment = "Production"
        CreatedBy   = "ImageBuilder"
        BuildDate   = "{{ imagebuilder:buildDate }}"
      }
      
      # Configure launch permissions
      launch_permission {
        # Uncomment to allow specific accounts to launch instances from this AMI
        # account_ids = ["123456789012", "098765432109"]
      }
    }
  }
}  

resource "aws_imagebuilder_component" "update_os" {
  data = yamlencode({
    phases = [
      {
      name = "build"     
      steps = [
        {
        name      = "UpdateWIN"
        action = "UpdateOS"      
        onFailure = "Abort"
        }]}
        
        ]
    schemaVersion = 1.0
  })
  name     = "WinUpdates"
  platform = "Windows"
  version  = "1.0.0"
}

resource "aws_imagebuilder_component" "aws_cli" {
  data = yamlencode({
    phases = [
      {
        name = "build"
        steps = [
          {
            name = "Download"
            action ="S3Download"
            inputs = [{ "destination" : "C:\\Windows\\Temp\\AWSCLI64PY3.msi", "source" : "s3://${var.asset_bucket}/AWSCLIV2.msi"}]
          },
          {
            name      = "InstallAWSCLI"
            action = "ExecuteBinary"
            inputs = { "path" : "C:\\Windows\\System32\\msiexec.exe", "arguments" : [ "/i", "{{ build.Download.inputs[0].destination }}",  "/qn" , "/norestart" ] }
            onFailure = "Continue"
          }

        ]
        
      }
    ]
     schemaVersion = 1.0
  })
  name     = "AWSCLI"
  platform = "Windows"
  version  = "1.22.87"
#  kms_key_id = var.kms_key
}


resource "aws_imagebuilder_component" "newrelic_install" {
  data = yamlencode({
    phases = [
      {
        name = "build"
        steps = [
          {
            name = "Download"
            action ="S3Download"
            inputs = [{ "destination" : "C:\\Windows\\Temp\\newrelic-infra.msi",  "source" : "s3://${var.asset_bucket}/newrelic-infra.msi"}]
          },
          {
            name = "Install"
            action = "ExecuteBinary"
            inputs = { "path" :  "C:\\Windows\\System32\\msiexec.exe" , "arguments" : [ "/qn", "/i", "{{ build.Download.inputs[0].destination }}", "GENERATE_CONFIG=true", "LICENSE_KEY='1234'" ] }
            
            onFailure = "Continue"

          }

        ]
        
      }
]
     schemaVersion = 1.0
  })
  name     = "Newrelic"
  platform = "Windows"
  version  = "1.0.0"
#  kms_key_id = var.kms_key
  }

resource "aws_imagebuilder_component" "kinesis_config" {
  data = yamlencode({
    phases = [
      {
        name = "build"
        steps = [
          {
            name = "Download"
            action ="S3Download"
            inputs = [{ "destination" : "C:\\Program Files\\Amazon\\AWSKinesisTap\\appsettings.json", "source" : "s3://${var.asset_bucket}/appsettings.json"}]
          }

        ]
        
      }
]
     schemaVersion = 1.0
  })
  name     = "KinesisConfig"
  platform = "Windows"
  version  = "1.0.0"
#  kms_key_id = var.kms_key
  }

