 tkn pipeline start petclinic-pipeline --param buildnumber=$(date +%s) \
       --workspace name=pipeline-ws,volumeClaimTemplateFile=workspace-template.yaml \
       --workspace name=argo-app-ws,volumeClaimTemplateFile=workspace-template.yaml \
       --workspace name=git-app-config-ssh-creds,secret=github-pipeline-config-petclinic-ssh-key \
       --use-param-defaults

