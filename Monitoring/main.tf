provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "monitoring_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              
              useradd --no-create-home --shell /bin/false prometheus
              mkdir /etc/prometheus /var/lib/prometheus

              cd /tmp
              curl -LO https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
              tar xvf prometheus-2.52.0.linux-amd64.tar.gz
              cd prometheus-2.52.0.linux-amd64

              cp prometheus /usr/local/bin/
              cp promtool /usr/local/bin/
              cp -r consoles/ console_libraries/ /etc/prometheus/

              cat <<EOT > /etc/prometheus/prometheus.yml
              global:
                scrape_interval: 15s

              scrape_configs:
                - job_name: 'prometheus'
                  static_configs:
                    - targets: ['localhost:9090']
              EOT

              useradd grafana -s /bin/false
              apt install -y apt-transport-https software-properties-common wget
              wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
              add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
              apt update -y
              apt install -y grafana

              systemctl daemon-reexec
              systemctl enable grafana-server
              systemctl start grafana-server

              nohup prometheus --config.file=/etc/prometheus/prometheus.yml > /var/log/prometheus.log 2>&1 &
              EOF

  tags = {
    Name = "Prometheus-Grafana"
  }
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI for us-east-1"
  default     = "ami-03f4878755434977f"
}

resource "aws_security_group" "allow_monitoring_ports" {
  name        = "prometheus_grafana"
  description = "Allow Prometheus and Grafana ports"

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
