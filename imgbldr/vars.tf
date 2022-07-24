#ariable "tags" { }

variable "region_info" {

}

variable "account_id" {
    
}
variable "partition_info"{
    
}

variable "inst_profile" {}

variable "subnet_id" {
    default =""

}

variable "p_subnet_id"{
    default =""
}

variable "sec_grp" {
    type = list(string)
    default =[]

}

variable "logging_bucket" {
    
}

variable "asset_bucket" {

}

#variable "kms_key" {

#}

#variable "kms_key_ebs" {
    
#}