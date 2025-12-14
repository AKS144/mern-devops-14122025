$BACKUP_NAME = "auto-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$VOLUME_NAME = "mongo-storage"

Write-Host "`n=== [1/7] MANUAL STEP: ADD DATA ===" -ForegroundColor Yellow
Write-Host "1. Open a NEW TERMINAL and run: kubectl port-forward svc/frontend-service 8080:80"
Write-Host "2. Open Browser: http://localhost:8080"
Write-Host "3. Add Task: 'SURVIVOR DATA'"
Write-Host "4. Come back here and PRESS ENTER."
Read-Host "Waiting..."

Write-Host "`n=== [2/7] PREPARING FOR BACKUP ===" -ForegroundColor Cyan
kubectl annotate pod mongo-0 backup.velero.io/backup-volumes=$VOLUME_NAME --overwrite

Write-Host "`n=== [3/7] CREATING BACKUP: $BACKUP_NAME ===" -ForegroundColor Cyan
velero backup create $BACKUP_NAME --include-namespaces default --default-volumes-to-fs-backup --wait

# Verify Data Bytes
$CHECK = kubectl -n velero get podvolumebackups -l velero.io/backup-name=$BACKUP_NAME
$CHECK | Out-String
if ($CHECK -match "COMPLETED") { Write-Host " -> DATA CAPTURED!" -ForegroundColor Green } 
else { Write-Host " -> ERROR: No data captured. Stopping."; exit }

Write-Host "`n=== [4/7] DISASTER (DELETING ALL) ===" -ForegroundColor Red
kubectl delete deployment backend frontend
kubectl delete statefulset mongo
kubectl delete pvc --all
Write-Host " -> Resources Deleted."

Write-Host "`n=== [5/7] RESTORING ===" -ForegroundColor Cyan
velero restore create --from-backup $BACKUP_NAME --wait

Write-Host "`n=== [6/7] WAITING FOR PODS ===" -ForegroundColor Cyan
do {
    $pods = kubectl get pods --field-selector=status.phase=Running
    Write-Host " -> Waiting..."
    Start-Sleep -Seconds 5
} until ($pods -match "mongo-0")
Start-Sleep -Seconds 20

Write-Host "`n=== [7/7] FIXING DATABASE CONNECTION ===" -ForegroundColor Cyan
kubectl exec -it mongo-0 -- mongosh -u admin -p password123 --authenticationDatabase admin --eval "try { rs.reconfig(rs.conf(), {force: true}) } catch(e) { rs.initiate({_id: 'rs0', members: [{_id: 0, host: 'mongo-0.mongo-service.default.svc.cluster.local:27017'}, {_id: 1, host: 'mongo-1.mongo-service.default.svc.cluster.local:27017'}, {_id: 2, host: 'mongo-2.mongo-service.default.svc.cluster.local:27017'}]}) }"

kubectl rollout restart deployment backend

Write-Host "`nDONE! Refresh http://localhost:8080 to see your data." -ForegroundColor Green