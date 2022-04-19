export db_name=$1
export test_name=$2 # output will be stored at $git_root/out/$test_name/

bash build/$db_name.sh $test_name