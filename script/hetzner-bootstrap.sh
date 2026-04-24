#!/usr/bin/env bash
# One-shot Hetzner server bootstrap for Kamal deploys.
# Usage: ssh root@91.98.29.147 'bash -s' < script/hetzner-bootstrap.sh
# Idempotent — safe to re-run.

set -euo pipefail

echo "==> apt update + upgrade"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get upgrade -y -qq

echo "==> install base packages"
apt-get install -y -qq \
  docker.io \
  curl \
  git \
  ufw \
  unattended-upgrades \
  fail2ban

echo "==> ensure deploy user exists (Docker group)"
if ! id -u deploy >/dev/null 2>&1; then
  useradd -m -s /bin/bash -G docker deploy
else
  usermod -aG docker deploy
fi

echo "==> mirror root authorized_keys to deploy (no new keys added)"
install -o deploy -g deploy -m 700 -d /home/deploy/.ssh
install -o deploy -g deploy -m 600 /root/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys

echo "==> firewall: deny incoming except SSH, 80, 443"
ufw --force reset >/dev/null
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo "==> harden SSH (key-only, root login via key only)"
cat > /etc/ssh/sshd_config.d/99-harden.conf <<'EOF'
PermitRootLogin prohibit-password
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
EOF
systemctl reload ssh

echo "==> enable unattended security upgrades"
cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

echo "==> ensure docker running + enabled"
systemctl enable --now docker

echo "==> done. Connect as: ssh deploy@\$(hostname -I | awk '{print \$1}')"
