locals {
name = "sockshop"
prisub01 = "subnet-081d4fbe24fe14eb3"
prisub02 = "subnet-0b52ce5807b25b7b6"
prisub03 = "subnet-0615c53fa2d76195c"
pubsub01 = "subnet-017633c13844dd8ad"
pubsub02 = "subnet-05b16e1e921415ab4"
pubsub03 = "subnet-02ae9ec797416faca"
vpc = "vpc-00ebefe8a3bd1852c"
}

data "aws_vpc" "vpc"{
    id = local.vpc
}
data "aws_subnet" "prisub01"{
    id = local.prisub01
}
data "aws_subnet" "prisub02"{
    id = local.prisub02
}
data "aws_subnet" "prisub03"{
    id = local.prisub03
}
data "aws_subnet" "pubsub01"{
    id = local.pubsub01
}
data "aws_subnet" "pubsub02"{
    id = local.pubsub02
}
data "aws_subnet" "pubsub03"{
    id = local.pubsub03
}

module "bastion" {
    source = "./module/bastion"
    ami = "ami-0694d931cee176e7d"
    instance = "t2.medium"
    private-key = module.Sg-keypair.private-key
    subnets = data.aws_subnet.pubsub01.id
    bastionsg = [module.Sg-keypair.bastionsg]
    key_name = module.Sg-keypair.key_name
    }

module "masternode"{
    source = "./module/masternode"
    instancecount = 3
    ami = "ami-0694d931cee176e7d"
    instance = "t2.medium"
    key_name = module.Sg-keypair.key_name
    ms-sg= [module.Sg-keypair.k8s-sg]
    subnet_id = [data.aws_subnet.prisub01.id,data.aws_subnet.prisub02.id,data.aws_subnet.prisub03.id]
   
}

module "workernode"{
    source = "./module/workernode"
    instancecount = 3
    ami = "ami-0694d931cee176e7d"
    instance = "t2.medium"
    key_name = module.Sg-keypair.key_name
    k8s-sg= [module.Sg-keypair.k8s-sg]
    subnet_ids = [data.aws_subnet.prisub01.id,data.aws_subnet.prisub02.id,data.aws_subnet.prisub03.id]
}


module "haproxy"{
    source = "./module/haproxy"
    ami = "ami-0694d931cee176e7d"
    instance = "t2.medium"
    key_name = module.Sg-keypair.key_name
    haproxysg=module.Sg-keypair.k8s-sg
    master1 = module.masternode.masternode_host[0]
    master2 = module.masternode.masternode_host[1]
    master3 = module.masternode.masternode_host[2]
    subnet1 = data.aws_subnet.prisub01.id
    subnet2 = data.aws_subnet.prisub02.id
}

module "env-lb" {
    source   = "./module/env-lb"
    vpc      = data.aws_vpc.vpc.id
    subnet3  = [data.aws_subnet.pubsub02.id,data.aws_subnet.pubsub01.id,data.aws_subnet.pubsub03.id]
    lb-sg    = [module.Sg-keypair.k8s-sg]
    instance = module.workernode.workernode-id
    cert_arn = module.route53.aws_certificate
}

module "Sg-keypair" {
    source = "./module/Sg-keypair"
    vpc    = data.aws_vpc.vpc.id

}

module "monitoring-lb"{
    source     = "./module/monitoring-lb"
    instance   = module.workernode.workernode-id
    k8s-sg     = [module.Sg-keypair.k8s-sg]
    subnet4    = [data.aws_subnet.pubsub01.id,data.aws_subnet.pubsub02.id,data.aws_subnet.pubsub03.id]
    vpc        = data.aws_vpc.vpc.id
    cert_arn   = module.route53.aws_certificate
}

module "route53" {
    source = "./module/route53"
    domain = "pra.gen.in"
    domain1 = "stage.pra.gen.in"
    domain2 = "prod.pra.gen.in"
    domain3 = "graf.pra.gen.in"
    domain4 = "prom.pra.gen.in"
    domain5 = "*.pra.gen.in"
    stage_lb_dns_name = module.env-lb.stage-dns-name
    stage_lb_zoneid = module.env-lb.stage-zone-id
    prod_lb_dns_name = module.env-lb.prod-dns-name
    prod_lb_zoneid = module.env-lb.prod-zone-id
    graf_lb_dns_name = module.monitoring-lb.graf-dns-name
    graf_lb_zoneid = module.monitoring-lb.graf-zone-id
    prom_lb_dns_name = module.monitoring-lb.prom-dns-name
    prom_lb_zoneid = module.monitoring-lb.prom-zone-id
}

module "ansible" {
    source = "./module/ansible"
    ami = "ami-0694d931cee176e7d"
    instance = "t2.medium"
    private-key = module.Sg-keypair.private-key
    key_name = module.Sg-keypair.key_name
    subnet07 = data.aws_subnet.prisub01.id
    ansible-sg = [module.Sg-keypair.ansible-sg]
    haproxy1 = module.haproxy.haproxy1
    haproxy2 = module.haproxy.haproxy2
    main-master = module.masternode.masternode-id[0]
    member-master1 = module.masternode.masternode_host[1]
    member-master2 = module.masternode.masternode_host[2]
    worker01 = module.workernode.workernode_host[0]
    worker02 = module.workernode.workernode_host[1]
    worker03 = module.workernode.workernode_host[2]
    bastion_host_2 = module.bastion.bastion_host
  
}