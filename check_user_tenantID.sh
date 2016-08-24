#!/bin/bash
# Script per identificare utenti, tennat-id e project appartenenti
#

# Configurazioni iniziali
date=$(date +"%Y-%m-%d")
mkdir /tmp/$date/

VM_FILE=/tmp/$date/vm_file.txt
LOG_VM_IP=/tmp/$date/list_VM_USER_IP.txt

> $LOG_VM_IP


# Produce la lista delle VM e viene salvato l'ID in una lista
function list_vms_IP() {
   nova list --all_tenants | egrep -v "(+------|\| ID)" | \
   igawk -F '|' '
   @include trims.awk
   {print trim($2)}' > $VM_FILE
}



####
## MAIN --------------------------------------
##

list_vms_IP

# Per ciascuna delle VM della lista
for vm in `cat $VM_FILE`; do
   # Query user_id and tenant_id
   infor=(`nova show $vm | \
   igawk -F '|' '
      @include trims.awk
      /user_id/ {uid=trim($3)}
      /tenant_id/ {tid=trim($3)}
      /network/ {IP=trim($3)}
      END {print uid, tid, IP}
'`)

# ${infor[0]} = user_id ; ${infor[1]}=project_id

# Scrittura dei log 

echo " $vm # user=${infor[0]} tenant=${infor[1]} IP-interno=${infor[2]} IP-pubb=${infor[3]}" | tee -a $LOG_VM_IP

done
