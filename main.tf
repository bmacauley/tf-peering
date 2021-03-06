provider "aws" {
  alias = "source"
}

provider "aws" {
  alias = "dest"
}

data "aws_caller_identity" "dest" {
  provider = "aws.dest"
}

data "aws_vpc" "source" {
  provider = "aws.source"
  id       = "${var.vpc_source_vpc_id}"
}

data "aws_vpc" "dest" {
  provider = "aws.dest"
  id       = "${var.vpc_dest_vpc_id}"
}

resource "aws_vpc_peering_connection" "request" {
  provider = "aws.source"

  auto_accept   = "false"
  peer_owner_id = "${data.aws_caller_identity.dest.account_id}"
  peer_vpc_id   = "${var.vpc_dest_vpc_id}"
  vpc_id        = "${var.vpc_source_vpc_id}"

  tags {
    Side = "Requester"
  }

  tags = {
    Name = "${format("%s - %s", data.aws_vpc.source.tags, data.aws_vpc.dest.tags)}"
  }
}

resource "aws_vpc_peering_connection_accepter" "accept" {
  provider = "aws.dest"

  auto_accept               = true
  vpc_peering_connection_id = "${aws_vpc_peering_connection.request.id}"

  tags {
    Side = "Accepter"
  }

  tags = {
    Name = "${format("%s - %s", data.aws_vpc.dest.tags, data.aws_vpc.source.tags)}"
  }
}
