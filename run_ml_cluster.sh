#!/bin/sh
path=$(pwd)
if [ -d "/scratch-ssd/slurm-jobs/jh_super_cool_folder" ] 
then
    echo "Directory /scratch-ssd/slurm-jobs/jh_super_cool_folder exists" > "$path/output_t5_1.txt"
else
    mkdir "/scratch-ssd/slurm-jobs/jh_super_cool_folder"
    echo "Directory /scratch-ssd/slurm-jobs/jh_super_cool_folder does not exist; making new directory" > "$path/output_t5_1.txt"
fi
echo "it's kind of working" >> "$path/output_t5_1.txt"
cd "/scratch-ssd/slurm-jobs/jh_super_cool_folder"
echo "went into folder" >> "$path/output_t5_1.txt"
if [ ! -d "/scratch-ssd/slurm-jobs/jh_super_cool_folder/discourse_probing" ]
then
    git clone https://github.com/hotzjacobb/discourse_probing.git >> "$path/output_t5_1.txt"
    cd discourse_probing
    python3 -m venv env 
    echo '#!/bin/sh\n' > shebang.sh
    sed -i '1i #!/bin/sh\n' "/scratch-ssd/slurm-jobs/jh_super_cool_folder/discourse_probing/env/bin/activate" # add shebang
    echo $(cat env/bin/activate) >> "$path/output_t5_1.txt"    
    chmod 777 env/bin/activate
    . env/bin/activate
    ls
    pwd
    pip install -r requirements.txt >> "$path/output_t5_1.txt"
else
    cd discourse_probing
    . env/bin/activate
fi
cd dissent
echo "Setup finished; will now run code" >> "$path/output_t5_1.txt"
CUDA_VISIBLE_DEVICES=1 python probe.py \
    --model_type t5 \
    --output_folder /ubc/cs/home/j/jhotz/output2 \
    --train_data data/data_en/train.tsv \
    --dev_data data/data_en/dev.tsv \
    --test_data data/data_en/test.tsv \
    --seed 2 \
    --start 3 \
>> "$path/output_t5_1.txt" 
