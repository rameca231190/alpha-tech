Install velero

# Install Velero binary
wget https://github.com/vmware-tanzu/velero/releases/download/v1.3.2/velero-v1.3.2-linux-amd64.tar.gz

# Extract the tarball:
tar -xvf velero-v1.3.2-linux-amd64.tar.gz -C /tmp

# Move the extracted velero binary to /usr/local/bin
sudo mv /tmp/velero-v1.3.2-linux-amd64/velero /usr/local/bin

# Verify installation
velero version



# DR and PROD cluster

velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.0.1 \
    --bucket valero-backup-prod \
    --backup-location-config region=ap-south-1 \
    --snapshot-location-config region=ap-southeast-1 \
    --secret-file /root/.aws/credentials

# BACKUP AND RESTORE
 # Let’s back up the harshal namespace using velero
backup:
velero backup create <backupname> --include-namespaces <namespacename>
velero backup create test1 --include-namespaces harshal

velero backup create valero-backup-prod  --include-namespaces kuard,ingress-nginx,external-dns,cert-manager,kube-system


# describe backup 
velero backup describe valero-backup-prod


# Restore

velero restore create --from-backup valero-backup-prod-v1

DR:

hostname: a57436a1602644e6988c135e6fd00d35-1677895317.ap-south-1.elb.amazonaws.com

PROD:
hostname: ab25a35586c3e423f8533583ecb027b4-2126232371.ap-southeast-1.elb.amazonaws.com

# Schdedulle backup

velero schedule create prod-backup --schedule="@every 2h" --exclude-namespaces  default,kube-system,kube-node-lease,kube-public,velero,cert-manager,external-dns,ingress-nginx


# export BACKUP_NAME=$(velero backup get | awk {'print $1'} | head -2 | grep -i prod)
