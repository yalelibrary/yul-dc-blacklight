ecs-cli compose --project-name mml --file ecs-compose.yml service up \
  --cluster-config mml-cluster  \
  --ecs-profile mml-cluster-profile \
  -r us-east-2 \
  --private-dns-namespace local \
  --vpc vpc-09f1f13fcece6423a \
  --target-groups targetGroupArn=arn:aws:elasticloadbalancing:us-east-2:884493977791:targetgroup/mml-ecs-tg/e142e0a2ad7dc5c3,containerName=web,containerPort=3000 \
  --target-groups targetGroupArn=arn:aws:elasticloadbalancing:us-east-2:884493977791:targetgroup/iiiif-images/e874d0fe52a3df64,containerName=iiif_image,containerPort=8182  \
  --target-groups targetGroupArn=arn:aws:elasticloadbalancing:us-east-2:884493977791:targetgroup/iiif-mft/224efe459ea97e61,containerName=iiif_manifest,containerPort=80 
#  --container-name web \
#  --container-port 3000 
  #--enable-service-discovery #use first time
