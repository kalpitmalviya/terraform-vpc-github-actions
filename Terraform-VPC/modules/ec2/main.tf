# Define variables required for the configuration
variable "ec2_names" {
  type        = list(string)
  description = "A list of names for the EC2 instances."
  default     = ["web-server-1", "web-server-2"]
}

variable "sg_id" {
  type        = string
  description = "The ID of the security group to associate with the instances."
}

variable "subnets" {
  type        = list(string)
  description = "A list of subnet IDs for deploying the instances."
}

# Data source to fetch the most recent Amazon Linux 2 AMI
data "aws_ami" "amazon-ec2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source to get all available availability zones in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# Resource to create the EC2 instances
resource "aws_instance" "my_ec2" {
  count                       = length(var.ec2_names)
  ami                         = data.aws_ami.amazon-ec2.id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [var.sg_id]
  associate_public_ip_address = true
  subnet_id                   = var.subnets[count.index]
  availability_zone           = data.aws_availability_zones.available.names[count.index]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    
    # Fetch instance metadata for the HTML page
    INSTANCE_ID=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id)
    INSTANCE_TYPE=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-type)
    AVAILABILITY_ZONE=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    REGION=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/placement/region)
    
    # Create the HTML game page
    cat > /var/www/html/index.html <<EOT
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Tower of Hanoi</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
    
            body {
                font-family: 'Arial', sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                color: white;
            }
    
            .game-container {
                background: rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(10px);
                border-radius: 20px;
                padding: 30px;
                box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
                border: 1px solid rgba(255, 255, 255, 0.18);
            }
    
            h1 {
                text-align: center;
                margin-bottom: 20px;
                font-size: 2.5rem;
                text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
            }
    
            .game-info {
                display: flex;
                justify-content: space-between;
                margin-bottom: 30px;
                font-size: 1.2rem;
            }
    
            .towers-container {
                display: flex;
                justify-content: space-around;
                align-items: flex-end;
                height: 300px;
                margin-bottom: 30px;
                padding: 0 20px;
            }
    
            .tower {
                display: flex;
                flex-direction: column-reverse;
                align-items: center;
                width: 200px;
                height: 100%;
                position: relative;
            }
    
            .tower::before {
                content: '';
                position: absolute;
                bottom: 0;
                width: 180px;
                height: 10px;
                background: #8B4513;
                border-radius: 5px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.3);
            }
    
            .tower::after {
                content: '';
                position: absolute;
                bottom: 10px;
                width: 8px;
                height: 250px;
                background: #8B4513;
                border-radius: 4px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.3);
            }
    
            .disk {
                height: 25px;
                border-radius: 12px;
                margin: 2px 0;
                cursor: grab;
                position: relative;
                z-index: 10;
                transition: all 0.3s ease;
                box-shadow: 0 4px 12px rgba(0,0,0,0.3);
                border: 2px solid rgba(255,255,255,0.3);
            }
    
            .disk:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 16px rgba(0,0,0,0.4);
            }
    
            .disk.dragging {
                cursor: grabbing;
                transform: rotate(5deg) scale(1.05);
                z-index: 1000;
            }
    
            .disk-1 { width: 60px; background: linear-gradient(45deg, #ff6b6b, #ee5a5a); }
            .disk-2 { width: 80px; background: linear-gradient(45deg, #4ecdc4, #44a08d); }
            .disk-3 { width: 100px; background: linear-gradient(45deg, #45b7d1, #3498db); }
            .disk-4 { width: 120px; background: linear-gradient(45deg, #f39c12, #e67e22); }
            .disk-5 { width: 140px; background: linear-gradient(45deg, #9b59b6, #8e44ad); }
    
            .tower.highlight {
                background: rgba(255, 255, 255, 0.2);
                border-radius: 10px;
                transform: scale(1.02);
            }
    
            .controls {
                display: flex;
                justify-content: center;
                gap: 20px;
                margin-top: 20px;
            }
    
            button {
                background: linear-gradient(45deg, #667eea, #764ba2);
                color: white;
                border: none;
                padding: 12px 24px;
                border-radius: 25px;
                font-size: 16px;
                cursor: pointer;
                transition: all 0.3s ease;
                box-shadow: 0 4px 12px rgba(0,0,0,0.2);
            }
    
            button:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 16px rgba(0,0,0,0.3);
            }
    
            .win-message {
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                background: rgba(0, 0, 0, 0.9);
                color: white;
                padding: 30px;
                border-radius: 15px;
                text-align: center;
                font-size: 1.5rem;
                display: none;
                z-index: 2000;
                backdrop-filter: blur(10px);
            }
        </style>
    </head>
    <body>
        <div class="game-container">
            <h1>🗼 Tower of Hanoi</h1>
            
            <div class="game-info">
                <div>Moves: <span id="moves">0</span></div>
                <div>Min Moves: <span id="minMoves">31</span></div>
                <div>Time: <span id="time">00:00</span></div>
            </div>
    
            <div class="towers-container">
                <div class="tower" data-tower="0">
                    <div class="disk disk-5" data-size="5"></div>
                    <div class="disk disk-4" data-size="4"></div>
                    <div class="disk disk-3" data-size="3"></div>
                    <div class="disk disk-2" data-size="2"></div>
                    <div class="disk disk-1" data-size="1"></div>
                </div>
                <div class="tower" data-tower="1"></div>
                <div class="tower" data-tower="2"></div>
            </div>
    
            <div class="controls">
                <button onclick="resetGame()">Reset Game</button>
                <button onclick="showSolution()">Show Solution</button>
            </div>
        </div>
    
        <div class="win-message" id="winMessage">
            <h2>🎉 Congratulations!</h2>
            <p>You solved the Tower of Hanoi!</p>
            <p>Moves: <span id="finalMoves"></span></p>
            <p>Time: <span id="finalTime"></span></p>
            <button onclick="resetGame()">Play Again</button>
        </div>
    
        <script>
            let moves = 0;
            let startTime = null;
            let gameTimer = null;
            let draggedDisk = null;
            let gameWon = false;
    
            const towers = [
                [5, 4, 3, 2, 1], // Tower 0 (left)
                [],              // Tower 1 (middle)
                []               // Tower 2 (right)
            ];
    
            function updateDisplay() {
                document.getElementById('moves').textContent = moves;
                
                if (startTime) {
                    const elapsed = Math.floor((Date.now() - startTime) / 1000);
                    const minutes = Math.floor(elapsed / 60).toString().padStart(2, '0');
                    const seconds = (elapsed % 60).toString().padStart(2, '0');
                    document.getElementById('time').textContent = `${minutes}:${seconds}`;
                }
            }
    
            function startTimer() {
                if (!startTime) {
                    startTime = Date.now();
                    gameTimer = setInterval(updateDisplay, 1000);
                }
            }
    
            function stopTimer() {
                if (gameTimer) {
                    clearInterval(gameTimer);
                    gameTimer = null;
                }
            }
    
            function checkWin() {
                if (towers[2].length === 5 && !gameWon) {
                    gameWon = true;
                    stopTimer();
                    document.getElementById('finalMoves').textContent = moves;
                    document.getElementById('finalTime').textContent = document.getElementById('time').textContent;
                    document.getElementById('winMessage').style.display = 'block';
                }
            }
    
            function canPlaceDisk(diskSize, towerIndex) {
                const tower = towers[towerIndex];
                return tower.length === 0 || tower[tower.length - 1] > diskSize;
            }
    
            function moveDisk(fromTower, toTower) {
                if (towers[fromTower].length === 0) return false;
                
                const diskSize = towers[fromTower][towers[fromTower].length - 1];
                if (!canPlaceDisk(diskSize, toTower)) return false;
    
                // Move disk in data structure
                const disk = towers[fromTower].pop();
                towers[toTower].push(disk);
    
                // Move disk in DOM
                const fromTowerElement = document.querySelector(`[data-tower="${fromTower}"]`);
                const toTowerElement = document.querySelector(`[data-tower="${toTower}"]`);
                const diskElement = fromTowerElement.querySelector(`[data-size="${disk}"]`);
                
                toTowerElement.appendChild(diskElement);
                
                moves++;
                startTimer();
                updateDisplay();
                checkWin();
                return true;
            }
    
            function resetGame() {
                gameWon = false;
                moves = 0;
                startTime = null;
                stopTimer();
                
                // Reset data structure
                towers[0] = [5, 4, 3, 2, 1];
                towers[1] = [];
                towers[2] = [];
    
                // Reset DOM
                const leftTower = document.querySelector('[data-tower="0"]');
                const middleTower = document.querySelector('[data-tower="1"]');
                const rightTower = document.querySelector('[data-tower="2"]');
    
                // Clear all towers
                [leftTower, middleTower, rightTower].forEach(tower => {
                    while (tower.firstChild) {
                        tower.removeChild(tower.firstChild);
                    }
                });
    
                // Add disks back to left tower
                for (let i = 5; i >= 1; i--) {
                    const disk = document.createElement('div');
                    disk.className = `disk disk-${i}`;
                    disk.setAttribute('data-size', i);
                    disk.draggable = true;
                    leftTower.appendChild(disk);
                }
    
                updateDisplay();
                document.getElementById('winMessage').style.display = 'none';
            }
    
            function showSolution() {
                alert('Try to move all disks from the left tower to the right tower!\n\nRules:\n1. Only move one disk at a time\n2. Only move the top disk from a tower\n3. Never place a larger disk on a smaller one\n\nMinimum moves needed: 31');
            }
    
            // Drag and Drop functionality
            document.addEventListener('dragstart', function(e) {
                if (!e.target.classList.contains('disk')) return;
                
                const tower = e.target.parentElement;
                const topDisk = tower.lastElementChild;
                
                if (e.target !== topDisk) {
                    e.preventDefault();
                    return;
                }
                
                draggedDisk = e.target;
                e.target.classList.add('dragging');
                e.dataTransfer.effectAllowed = 'move';
            });
    
            document.addEventListener('dragend', function(e) {
                if (e.target.classList.contains('disk')) {
                    e.target.classList.remove('dragging');
                }
                document.querySelectorAll('.tower').forEach(tower => {
                    tower.classList.remove('highlight');
                });
            });
    
            document.addEventListener('dragover', function(e) {
                e.preventDefault();
                e.dataTransfer.dropEffect = 'move';
            });
    
            document.addEventListener('dragenter', function(e) {
                if (e.target.classList.contains('tower')) {
                    const towerIndex = parseInt(e.target.dataset.tower);
                    const diskSize = parseInt(draggedDisk.dataset.size);
                    
                    if (canPlaceDisk(diskSize, towerIndex)) {
                        e.target.classList.add('highlight');
                    }
                }
            });
    
            document.addEventListener('dragleave', function(e) {
                if (e.target.classList.contains('tower')) {
                    e.target.classList.remove('highlight');
                }
            });
    
            document.addEventListener('drop', function(e) {
                e.preventDefault();
                
                if (!e.target.classList.contains('tower') || !draggedDisk) return;
                
                const toTowerIndex = parseInt(e.target.dataset.tower);
                const fromTowerIndex = parseInt(draggedDisk.parentElement.dataset.tower);
                const diskSize = parseInt(draggedDisk.dataset.size);
                
                if (canPlaceDisk(diskSize, toTowerIndex) && fromTowerIndex !== toTowerIndex) {
                    moveDisk(fromTowerIndex, toTowerIndex);
                }
                
                draggedDisk = null;
            });
    
            // Initialize game
            updateDisplay();
        </script>
    </body>
    </html>
    EOT
  EOF

  tags = {
    Name             = var.ec2_names[count.index]
    update_timestamp = timestamp()
  }
}
