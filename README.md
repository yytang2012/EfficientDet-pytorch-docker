# EfficientDet-Pytorch-docker
A docker build file for EfficientDet: 
https://github.com/zylo117/Yet-Another-EfficientDet-Pytorch.git


### Requirements
- Nvidia Docker runtime: https://github.com/NVIDIA/nvidia-docker#quickstart
- CUDA 10.1 or higher on your host, check with `nvidia-smi`

### Prepare your dataset
- your dataset structure should be like this
    ```shell script
    datasets/
        -your_project_name/
            -train_set_name/
                -*.jpg
            -val_set_name/
                -*.jpg
            -annotations
                -instances_{train_set_name}.json
                -instances_{val_set_name}.json
    ```

- for example, coco2017
    ```shell script
    datasets/
        -coco2017/
            -train2017/
                -000000000001.jpg
                -000000000002.jpg
                -000000000003.jpg
            -val2017/
                -000000000004.jpg
                -000000000005.jpg
                -000000000006.jpg
            -annotations
                -instances_train2017.json
                -instances_val2017.json
    
    ```
### Host machine
- Build image 
    ```shell script
    docker build . -t efficientdet:latest
    ```

- Run container
    ```shell script
    docker run -it --rm --runtime=nvidia efficientdet:latest /bin/bash
    ```
    or
    ```shell script
      export WORK_DIR=~/Documents/efficientDet/ && \
      mkdir -p $WORK_DIR/weights && \
      mkdir -p $WORK_DIR/logs && \
      docker run  -v $WORK_DIR/weights:/efficientdet/weights \
      -v $WORK_DIR/datasets:/datasets \
      -v $WORK_DIR/logs:/logs \
      -v /etc/localtime:/etc/localtime \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -e DISPLAY=$DISPLAY -e QT_X11_NO_MITSHM=1  \
      -it --rm --runtime=nvidia \
      --name efficientdet efficientdet:latest  /bin/bash
    ```
  

- Download pretrain weights
    ```shell script
      export WEIGHT_DIR=~/Documents/efficientDet/weights/
      wget -nc -P $WEIGHT_DIR https://github.com/zylo117/Yet-Another-Efficient-Pytorch/releases/download/1.0/efficientdet-d0.pth
      wget -nc -P $WEIGHT_DIR https://github.com/zylo117/Yet-Another-Efficient-Pytorch/releases/download/1.0/efficientdet-d1.pth
      wget -nc -P $WEIGHT_DIR https://github.com/zylo117/Yet-Another-Efficient-Pytorch/releases/download/1.0/efficientdet-d2.pth
      wget -nc -P $WEIGHT_DIR https://github.com/zylo117/Yet-Another-Efficient-Pytorch/releases/download/1.0/efficientdet-d3.pth
      wget -nc -P $WEIGHT_DIR https://github.com/zylo117/Yet-Another-Efficient-Pytorch/releases/download/1.0/efficientdet-d4.pth
      wget -nc -P $WEIGHT_DIR https://github.com/zylo117/Yet-Another-Efficient-Pytorch/releases/download/1.0/efficientdet-d5.pth
      wget -nc -P $WEIGHT_DIR https://github.com/zylo117/Yet-Another-Efficient-Pytorch/releases/download/1.0/efficientdet-d6.pth
    ```


- Converting a training model to inference model
    - Running directly from the repository:
    
        `keras_retinanet/bin/convert_model.py /path/to/training/model.h5 /path/to/save/inference/model.h5`

    - Using the installed script:
    
        `retinanet-convert-model /path/to/training/model.h5 /path/to/save/inference/model.h5`

- Save and Load docker image
    ```shell script
      docker save retinanet > retinanet.tar
      docker load < retinanet.tar
    ```

### In container
- Train Coco dataset in container
    ```shell script
      cd /efficientdet && \
      python3 train.py --project item \
        -c 0 \
        --data_path /datasets/ \
        --num_workers 2 \
        --batch_size 2 \
        --log_path /logs \
        --saved_path /logs \
        --num_epochs 500

    ```
- Resume training from a snapshot
    ```shell script
      cd /retinanet/keras_retinanet/bin && \
      python3 train.py --snapshot /snapshots/resnet50_coco_50.h5 \
        --initial-epoch 50 --epochs 100 \
        coco /datasets/coco/
    ```

The retinaNet repo is in `/retinanet`

### Possible issue
If meet the following error `: cannot connect to X server :1`

then run
`xhost local:root`