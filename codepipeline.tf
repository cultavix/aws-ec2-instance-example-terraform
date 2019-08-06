resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = var.codepipeline_artifact_bucket_name
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }
  lifecycle_rule {
    id      = "all"
    enabled = true
    expiration {
      days = var.codepipeline_artifact_expiration
    }
  }
  tags = {
    Name           = var.codepipeline_artifact_bucket_name
    Application    = "N/A"
    Environment    = "Production"
    InfraManagedBy = "CloudPlatform"
    AppManagedBy   = "N/A"
  }
}

# resource "aws_codepipeline" "codepipeline" {
#   name     = var.codepipeline_name
#   role_arn = aws_iam_role.pipeline_role.arn
#   artifact_store {
#     location = aws_s3_bucket.codepipeline_artifacts.id
#     type     = "S3"
#   }

# ## Source Stage (no magic, just straight code and vars)
#   stage {
#     name = "Source"
#     action {
#       name             = "Source"
#       category         = "Source"
#       owner            = "AWS"
#       provider         = "CodeCommit"
#       version          = "1"
#       output_artifacts = ["Source"]
#       configuration = {
#         RepositoryName = var.codecommit_name
#         BranchName     = var.codepipeline_source_branch
#       }
#     }
#   }
# ## Dynamic Stages for each environment
#   dynamic "stage" {
#     for_each               = local.stages

#     content {
#       name = stage.value["name"]
#         action {
#           name             = stage.value["name"]
#           category         = stage.value.category
#           owner            = stage.value.owner
#           provider         = stage.value.provider
#           version          = stage.value.version
#           output_artifacts = stage.value.output_artifacts
#           configuration    = stage.value.configuration
#         }
#     }
#   }

#   dynamic "stage" {
#     for_each = local.stages

#     type              = each.value["type"]
#     source_identifier = each.value["codebuild_secondary_source_identifier"]
#     location          = each.value["codebuild_secondary_source_location"]
#   }
#   tags = var.codepipeline_tags
# }

locals {
  secondary_sources = [{
    type              = var.codebuild_secondary_source_type
    source_identifier = var.codebuild_secondary_source_identifier
    location          = var.codebuild_secondary_source_location
  }]
  # Ec2 Instance
  instances = {
    instance_type1 = "t2.small"
    instance_type2 = "t2.small"
  }
  # CodePipeline
  stages = {
    name            = "Apply"
    category        = "Build"
    owner           = "AWS"
    provider        = "CodeBuild"
    version         = "1"
    input_artifacts = ["Source"]
    configuration = {
      ProjectName = var.codebuild_project_name
    }
  }
}