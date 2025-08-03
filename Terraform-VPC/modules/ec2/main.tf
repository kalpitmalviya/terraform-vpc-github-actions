resource "aws_instance" "my_ec2" {
  count = length(var.ec2_names)
  ami   = data.aws_ami.amazon-ec2.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [var.sg_id]
  associate_public_ip_address = true
  subnet_id = var.subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              
              # Fetch instance metadata from the correct, static metadata service IP
              INSTANCE_ID=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id)
              INSTANCE_TYPE=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-type)
              AVAILABILITY_ZONE=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
              REGION=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/placement/region)
              
              # Create a modern HTML page with the correct values
              cat > /var/www/html/index.html <<EOT
              <!DOCTYPE html>
              <html>
              <head>
                  <title>EC2 Instance Info</title>
                  <style>
                      body {
                          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                          background-color: #f0f2f5;
                          margin: 0;
                          padding: 2rem;
                          display: flex;
                          justify-content: center;
                          align-items: center;
                          min-height: 100vh;
                          text-align: center;
                      }
                      .card {
                          background-color: #ffffff;
                          border-radius: 16px;
                          box-shadow: 0 12px 24px rgba(0, 0, 0, 0.1);
                          padding: 2rem;
                          width: 100%;
                          max-width: 450px;
                          color: #333;
                      }
                      h1 {
                          color: #6a1b9a;
                          font-size: 1.5rem;
                          margin-bottom: 2rem;
                          font-weight: 600;
                      }
                      .info-section {
                          margin-bottom: 1.5rem;
                      }
                      .info-label {
                          color: #888;
                          font-size: 0.9rem;
                          margin-bottom: 0.25rem;
                          font-weight: 500;
                      }
                      .info-value {
                          font-size: 1.2rem;
                          font-weight: bold;
                          color: #333;
                      }
                      .status-section {
                          margin-top: 2rem;
                      }
                      .status-label {
                          font-weight: 600;
                          color: #4CAF50;
                          font-size: 1.2rem;
                      }
                  </style>
              </head>
              <body>
                  <div class="card">
                      <h1>Your EC2 Instance is Running!</h1>
                      <div class="info-section">
                          <div class="info-label">Instance ID</div>
                          <div class="info-value">\$INSTANCE_ID</div>
                      </div>
                      <div class="info-section">
                          <div class="info-label">Instance Type</div>
                          <div class="info-value">\$INSTANCE_TYPE</div>
                      </div>
                      <div class="info-section">
                          <div class="info-label">Availability Zone</div>
                          <div class="info-value">\$AVAILABILITY_ZONE</div>
                      </div>
                      <div class="info-section">
                          <div class="info-label">Region</div>
                          <div class="info-value">\$REGION</div>
                      </div>
                      <div class="status-section">
                          <div class="status-label">Status: Running</div>
                      </div>
                  </div>
              </body>
              </html>
              EOT
              EOF

  tags = {
    Name = var.ec2_names[count.index]
    update_timestamp = timestamp()
  }
}