

resource "aws_iam_role" "ssm_automation_role" {
  name = "img-bldr-SSMAutomationRole-${random_id.bucket-id.dec}"
  path = "/"
  managed_policy_arns = ["arn:${var.partition_info}:iam::aws:policy/service-role/AmazonSSMAutomationRole",
    aws_iam_policy.img-bldr-golden-session-logging-s3.arn,
    aws_iam_policy.img-bldr-image-builder-policy.arn,
    "arn:${var.partition_info}:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:${var.partition_info}:iam::aws:policy/EC2InstanceProfileForImageBuilder",
    "arn:${var.partition_info}:iam::aws:policy/AWSImageBuilderFullAccess",
    "arn:${var.partition_info}:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"


  ]

  inline_policy {
    name = "PassRolePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : "iam:PassRole",
          "Resource" : "*"
        }
      ]
    })
  }
  assume_role_policy = jsonencode({

    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["ssm.amazonaws.com", "ec2.amazonaws.com", "imagebuilder.amazonaws.com"]
        },
        "Action" : [
          "sts:AssumeRole"
        ]
      }

    ]
  })

  tags = {
    "infosec-protected" = "true"
  }
  tags_all = {
    "infosec-protected" = "true"
  }

depends_on = [
  aws_iam_policy.img-bldr-golden-session-logging-s3,
  aws_iam_policy.img-bldr-image-builder-policy
]
}


resource "aws_iam_instance_profile" "golden-instance-profile" {
  name = "img-bldr-GoldenInstanceProfile-${random_id.bucket-id.dec}"
  path = "/"
  role = aws_iam_role.ssm_automation_role.name
  #role = "arn:${var.partition_info}:iam::aws:role/img-bldr-SSM-Automation-Role"
}


resource "aws_iam_policy" "img-bldr-golden-session-logging-s3" {
  name        = "img-bldr-golden-session-logging-s3-${random_id.bucket-id.dec}"
  path        = "/"
  description = "Grants access to S3 bucket in logging account for storing session logs"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:GetObject",
        "Resource" : [
          "arn:${var.partition_info}:s3:::aws-ssm-${var.region_info}/*",
          "arn:${var.partition_info}:s3:::aws-windows-downloads-${var.region_info}/*",
          "arn:${var.partition_info}:s3:::amazon-ssm-${var.region_info}/*",
          "arn:${var.partition_info}:s3:::amazon-ssm-packages-${var.region_info}/*",
          "arn:${var.partition_info}:s3:::${var.region_info}-birdwatcher-prod/*",
          "arn:${var.partition_info}:s3:::aws-ssm-distributor-file-${var.region_info}/*",
          "arn:${var.partition_info}:s3:::aws-ssm-document-attachments-${var.region_info}/*",
          "arn:${var.partition_info}:s3:::patch-baseline-snapshot-${var.region_info}/*",
          "arn:${var.partition_info}:imagebuilder:${var.region_info}:*:component/*",
          "arn:${var.partition_info}:imagebuilder:${var.region_info}:*:component/"



        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketLocation"

        ],
        "Resource" : [
          "arn:${var.partition_info}:s3:::${aws_s3_bucket.image-builder-logs.id}",
          "arn:${var.partition_info}:s3:::${aws_s3_bucket.image-builder-logs.id}/*",
          "arn:${var.partition_info}:s3:::${aws_s3_bucket.image-builder-bucket.id}",
          "arn:${var.partition_info}:s3:::${aws_s3_bucket.image-builder-bucket.id}/*"
          
        ]
      }
    ]
  })
}


resource "aws_iam_policy" "img-bldr-image-builder-policy" {
  name        = "img-bldr-image-builder-policy-${random_id.bucket-id.dec}"
  path        = "/"
  description = "Grants access to S3 bucket in logging account for storing session logs"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode(

    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:RunInstances"
          ],
          "Resource" : [
            "arn:aws:ec2:*::image/*",
            "arn:aws:ec2:*::snapshot/*",
            "arn:aws:ec2:*:*:subnet/*",
            "arn:aws:ec2:*:*:network-interface/*",
            "arn:aws:ec2:*:*:security-group/*",
            "arn:aws:ec2:*:*:key-pair/*",
            "arn:aws:ec2:*:*:launch-template/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:RunInstances"
          ],
          "Resource" : [
            "arn:aws:ec2:*:*:volume/*",
            "arn:aws:ec2:*:*:instance/*"
          ],
          "Condition" : {
            "StringEquals" : {
              "aws:RequestTag/CreatedBy" : [
                "EC2 Image Builder",
                "EC2 Fast Launch"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : "iam:PassRole",
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "iam:PassedToService" : [
                "ec2.amazonaws.com",
                "ec2.amazonaws.com.cn",
                "vmie.amazonaws.com"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:StopInstances",
            "ec2:StartInstances",
            "ec2:TerminateInstances"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "ec2:ResourceTag/CreatedBy" : "EC2 Image Builder"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CopyImage",
            "ec2:CreateImage",
            "ec2:CreateLaunchTemplate",
            "ec2:DeregisterImage",
            "ec2:DescribeImages",
            "ec2:DescribeInstanceAttribute",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeInstances",
            "ec2:DescribeInstanceTypeOfferings",
            "ec2:DescribeInstanceTypes",
            "ec2:DescribeSubnets",
            "ec2:DescribeTags",
            "ec2:ModifyImageAttribute",
            "ec2:DescribeImportImageTasks",
            "ec2:DescribeExportImageTasks",
            "ec2:DescribeSnapshots"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:ModifySnapshotAttribute"
          ],
          "Resource" : "arn:aws:ec2:*::snapshot/*",
          "Condition" : {
            "StringEquals" : {
              "ec2:ResourceTag/CreatedBy" : "EC2 Image Builder"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateTags"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "ec2:CreateAction" : [
                "RunInstances",
                "CreateImage"
              ],
              "aws:RequestTag/CreatedBy" : [
                "EC2 Image Builder",
                "EC2 Fast Launch"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateTags"
          ],
          "Resource" : [
            "arn:aws:ec2:*::image/*",
            "arn:aws:ec2:*:*:export-image-task/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateTags"
          ],
          "Resource" : [
            "arn:aws:ec2:*::snapshot/*",
            "arn:aws:ec2:*:*:launch-template/*"
          ],
          "Condition" : {
            "StringEquals" : {
              "aws:RequestTag/CreatedBy" : [
                "EC2 Image Builder",
                "EC2 Fast Launch"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "license-manager:UpdateLicenseSpecificationsForResource"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "sns:Publish"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:ListCommands",
            "ssm:ListCommandInvocations",
            "ssm:AddTagsToResource",
            "ssm:DescribeInstanceInformation",
            "ssm:GetAutomationExecution",
            "ssm:StopAutomationExecution",
            "ssm:ListInventoryEntries",
            "ssm:SendAutomationSignal",
            "ssm:DescribeInstanceAssociationsStatus",
            "ssm:DescribeAssociationExecutions"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "ssm:SendCommand",
          "Resource" : [
            "arn:aws:ssm:*:*:document/AWS-RunPowerShellScript",
            "arn:aws:ssm:*:*:document/AWS-RunShellScript",
            "arn:aws:ssm:*:*:document/AWSEC2-RunSysprep",
            "arn:aws:s3:::*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:SendCommand"
          ],
          "Resource" : [
            "arn:aws:ec2:*:*:instance/*"
          ],
          "Condition" : {
            "StringEquals" : {
              "ssm:resourceTag/CreatedBy" : [
                "EC2 Image Builder"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : "ssm:StartAutomationExecution",
          "Resource" : "arn:aws:ssm:*:*:automation-definition/ImageBuilder*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:CreateAssociation",
            "ssm:DeleteAssociation"
          ],
          "Resource" : [
            "arn:aws:ssm:*:*:document/AWS-GatherSoftwareInventory",
            "arn:aws:ssm:*:*:association/*",
            "arn:aws:ec2:*:*:instance/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncryptFrom",
            "kms:ReEncryptTo",
            "kms:GenerateDataKeyWithoutPlaintext"
          ],
          "Resource" : "*",
          "Condition" : {
            "ForAllValues:StringEquals" : {
              "kms:EncryptionContextKeys" : [
                "aws:ebs:id"
              ]
            },
            "StringLike" : {
              "kms:ViaService" : [
                "ec2.*.amazonaws.com"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "kms:DescribeKey"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "kms:ViaService" : [
                "ec2.*.amazonaws.com"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : "kms:CreateGrant",
          "Resource" : "*",
          "Condition" : {
            "Bool" : {
              "kms:GrantIsForAWSResource" : true
            },
            "StringLike" : {
              "kms:ViaService" : [
                "ec2.*.amazonaws.com"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : "sts:AssumeRole",
          "Resource" : "arn:aws:iam::*:role/EC2ImageBuilderDistributionCrossAccountRole"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogStream",
            "logs:CreateLogGroup",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:*:*:log-group:/aws/imagebuilder/*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateLaunchTemplateVersion",
            "ec2:DescribeLaunchTemplates",
            "ec2:ModifyLaunchTemplate",
            "ec2:DescribeLaunchTemplateVersions"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:ExportImage"
          ],
          "Resource" : "arn:aws:ec2:*::image/*",
          "Condition" : {
            "StringEquals" : {
              "ec2:ResourceTag/CreatedBy" : "EC2 Image Builder"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:ExportImage"
          ],
          "Resource" : "arn:aws:ec2:*:*:export-image-task/*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CancelExportTask"
          ],
          "Resource" : "arn:aws:ec2:*:*:export-image-task/*",
          "Condition" : {
            "StringEquals" : {
              "ec2:ResourceTag/CreatedBy" : "EC2 Image Builder"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : "iam:CreateServiceLinkedRole",
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "iam:AWSServiceName" : [
                "ssm.amazonaws.com",
                "ec2fastlaunch.amazonaws.com"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:EnableFastLaunch"
          ],
          "Resource" : [
            "arn:aws:ec2:*::image/*",
            "arn:aws:ec2:*:*:launch-template/*"
          ],
          "Condition" : {
            "StringEquals" : {
              "ec2:ResourceTag/CreatedBy" : "EC2 Image Builder"
            }
          }
        }
      ]
    }






  )
}

resource "random_id" "bucket-id" {
  byte_length = 2

}
resource "aws_s3_bucket" "image-builder-bucket" {
    bucket = "image-builder-assets-${random_id.bucket-id.dec}"
    acl ="private"
    force_destroy = true

    tags = {
        Name = "S3 Bucket for Image Builder"
    }
}

resource "aws_s3_bucket" "image-builder-logs" {
  bucket        = "image-builder-logs-${random_id.bucket-id.dec}"
  acl           = "private"
  force_destroy = true

  tags = {
    Name = "S3 Bucket for Image Builder logs"
  }
}
