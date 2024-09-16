#!/bin/bash
# Define variables

#!/bin/bash
# DIR is the directory where the script is saved (should be <project_root/scripts)
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd $DIR

MY_UID=$(id -u)
MY_GID=$(id -g)
MY_UNAME=$(id -un)
IMAGE=genai_sb:dev
# mount the scratch folders : assuming you have a relative soft link to scratch created by  'ln -s ../scratch.gkoren_gpu scratch'

HF_HOME=${HF_HOME:-/.cache/huggingface}
# if [ -d "/home/${MY_UNAME}/.cache/" ]; then
#     EXTRA_MOUNTS+=" --mount type=bind,source=/home/${MY_UNAME}/scratch,target=/home/${MY_UNAME}/scratch"
# fi

primary_git_folder=$(dirname $(dirname $(dirname ${DIR})))
if [ -d "${primary_git_folder}/clones/transformers" ]; then
  # Folder exists, perform actions and print value
  MOUNT_TRANSFORMERS="--mount type=bind,source=${primary_git_folder}/clones/transformers,target=${primary_git_folder}/clones/transformers"
  # You can add commands to interact with the folder here
else
  # Folder not found, print a message and abort
  echo "Error: please git clone transformers to ${primary_git_folder}/clones/transformers"
fi

if [ -d "${primary_git_folder}/clones/trl" ]; then
  # Folder exists, perform actions and print value
  MOUNT_TRL="--mount type=bind,source=${primary_git_folder}/clones/trl,target=${primary_git_folder}/clones/trl"
  # You can add commands to interact with the folder here
else
  # Folder not found, print a message and abort
  echo "Error: please git clone trl to ${primary_git_folder}/clones/tr"
fi


docker run \
    --gpus \"device=all\" \
    --privileged \
    --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 -it --rm \
    --mount type=bind,source=${DIR}/..,target=${DIR}/.. \
    --mount type=bind,source=${HF_HOME},target=/home/${MY_UNAME}/.cache/huggingface \
    ${MOUNT_TRANSFORMERS} \
    ${MOUNT_TRL} \
    --shm-size=8g \
    ${IMAGE}

#     -p 8889:8888 -p 6007:6006 --name gaisb_dev_1  \
# ${EXTRA_MOUNTS} \
cd -
