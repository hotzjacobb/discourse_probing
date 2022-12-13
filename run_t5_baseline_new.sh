#!/bin/bash
#SBATCH --time=06:00:00
#SBATCH --gres=gpu:4
#SBATCH --mem=8G
initial_path=$(pwd)
touch output_t5_1.txt
chmod 777 output_t5_1.txt
module load python/3.7
module load cuda cudnn
if [ ! -d "./discourse_probing" ]
then
    git clone https://github.com/hotzjacobb/discourse_probing.git >> output_t5_1.txt
    cd discourse_probing
    git checkout compute_can_python37
    virtualenv --no-download env
    chmod 777 env/bin/activate
    source env/bin/activate
    pip install --no-index --upgrade pip

    # This is the workflow for packages which have precompiled CC wheels, but the wheels are incompatible
    # with the project. Thus we must create a wheel for the project. CC had a whl for Pillow==8.4.0, but I
    # needed Pillow==9.3.0 for my project.
    cd ..
    git clone https://github.com/ComputeCanada/wheels_builder.git
    cd wheels_builder
    build_wheel.sh --package=Pillow --version=9.3.0 --python=3.7
    pip install Pillow-9.3.0+computecanada-cp37-cp37m-linux_x86_64.whl

    pip install -r --no-index requirements.txt >> ../output_t5_1.txt # CC has wheel
    pip install -r requirements_no_cc.txt >> ../output_t5_1.txt # CC does not have wheel
    wget https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-2.2.0/en_core_web_sm-2.2.0.tar.gz
    python -m spacy install en_core_web_sm-2.2.0.tar.gz
else
    cd discourse_probing
    source env/bin/activate
fi
cd dissent
module load python/3.7 cuda cudnn
echo "Setup finished; will now run code" >> ../output_t5_1.txt
CUDA_VISIBLE_DEVICES=0,1,2,3 python probe.py \
    --model_type t5-base \
    --output_folder ../../output1 \
    --train_data data/data_en/train.tsv \
    --dev_data data/data_en/dev.tsv \
    --test_data data/data_en/test.tsv \
    --seed 1 \
>> ../../output_t5_1.txt
touch ../../output_t5_2.txt
CUDA_VISIBLE_DEVICES=0,1,2,3 python probe.py \
    --model_type t5-base \
    --output_folder ../../output2 \
    --train_data data/data_en/train.tsv \
    --dev_data data/data_en/dev.tsv \
    --test_data data/data_en/test.tsv \
    --seed 2 \
>> ../../output_t5_2.txt
touch ../../output_t5_3.txt
CUDA_VISIBLE_DEVICES=0,1,2,3 python probe.py \
    --model_type t5-base \
    --output_folder ../../output3 \
    --train_data data/data_en/train.tsv \
    --dev_data data/data_en/dev.tsv \
    --test_data data/data_en/test.tsv \
    --seed 3 \
>> ../../output_t5_3.txt
