variable "project_name" {
    default = "roboshop"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "roboshop"
        Terraform = "true"
        Environment = "dev"
    }
}


variable "zone_name" {
    default = "devopswithaws.store"
}

variable "zone_id" {
    default = "Z01037242PFYQFQ71R7F6"
}