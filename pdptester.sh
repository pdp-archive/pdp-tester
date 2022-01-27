#!/bin/bash

function fetch_testdata() {
   # Fetch testdata if directory is not present.

   # Arg 1 : PDP contest (e.g. 22)
   # Arg 2 : codename (e.g. 'fire')
   # sed -i 's/\r//' fetch_testdata.sh
   if [ ! -d testdata/$1-PDP/$2 ]; then
      echo 'Fetching testdata for : ' $2
      mkdir tmp
      wget https://gitlab.com/pdp-archive/pdp-archive/-/archive/master/pdp-archive-master.zip?path=testdata/$1-PDP/$2 -O tmp/download.zip
      cd tmp
      unzip -q download.zip
      cd ..
      cp -r tmp/pdp-archive-master-testdata-$1-PDP-$2/testdata .
      rm -r tmp
   fi;
}

# "30-astrolavos"
pdpcodename=$1
splitArr=(${pdpcodename//-/ })
codename=${splitArr[1]}
pdp=${splitArr[0]}
executable=$2

time_limit=1
testcasesstr=""

while [ "$1" != "" ]; do
   case $1 in
      -t | --time_limit )  shift
         time_limit=$1
      ;;
      -c | --cases ) shift
         testcasesstr=$1
      ;;
      -h | --help )
         echo -e "bash pdptester <PDP no>-<problem codename> <executable> (--time_limit <seconds>) (--cases <cases to run>)\n"
         echo ""
         echo -e "Για παράδειγμα αν το όνομα αρχείου είναι a.exe (ή a.out) τότε,\nη εξής εντολή τρέχει όλα τα testcases.\n"
         echo -e "    bash pdptester 30-astrolavos a.out\n"
         echo -e "Αν θέλουμε να τρέξουμε μόνο τα testcases 1,3,5,6,7,9, μπορούμε\nνα το γράψουμε ως εξής (προσοχή δεν υπάρχουν κενά μεταξύ των αριθμών):\n"
         echo -e "    bash pdptester 30-astrolavos a.out --cases 1,3,5-7,9\n"
         echo -e "Ο προκαθορισμένος χρονικός περιορισμός είναι 1s. Μπορείτε να το\nαυξήσετε ως εξής:\n"
         echo -e "    bash pdptester 30-astrolavos a.out --time_limit 2\n"
         exit
      ;;
    esac
    shift
done

# echo "Time limit: ${time_limit}"
# echo "Testcases: ${testcasesstr}"

testcase_inp_template_name="testdata/${pdp}-PDP/${codename}/${codename}.in#"
testcase_out_template_name="testdata/${pdp}-PDP/${codename}/${codename}.out#"

fetch_testdata $pdp $codename

# If no tests are specified then execute all.
if [ -z "$testcasesstr" ]
then
   x=1
   while : ;do
      file=${testcase_inp_template_name/\#/$x}
      if [[ ! -f $file ]]; then
         break
      fi
      x=$((x+1))
   done
   x=$((x-1))
   testcasesstr="[1-${x}]"
fi

# Parse the testcases.
testcasesstr="${testcasesstr/[/}"
testcasesstr="${testcasesstr/]/}"
testranges=(${testcasesstr//,/ })
testcases=()

for i in "${testranges[@]}"
do
   if [[ $i =~ "-" ]]; then
      splitArr=(${i//-/ })
      st=${splitArr[0]}
      en=${splitArr[1]}
      for ((j=st;j<=en;j++)); do
         testcases+=($j)
      done
   else
      testcases+=($i)
   fi
done

# Step 1: Clear the tmp/ directory.
if [[ -x tmp/ ]]; then
   rm -r tmp/
fi;
mkdir tmp/
cd tmp/

# Step 2: Run the test cases.
echo -e "      Running the testcases.."
did_fail="false"
fixed_inp_name="${codename}.in"
fixed_out_name="${codename}.out"

for i in "${testcases[@]}";
do
   # Decode the input/output filenames.
   norm1=${testcase_inp_template_name/\#/$i}
   norm2=${testcase_out_template_name/\#/$i}
   # echo "Running ${i}"
   # Link the input with the canonical name.
   ln -sf ../${norm1} $fixed_inp_name
   # Run the code.
   timeout $time_limit ./../$executable
   # Check that no timeout occurred.
   if [ "$?" = 124 ]; then
      echo -e "         [\033[93mtimeout\033[0m] Test $i"
      did_fail="true"
   else
      result=$(diff --strip-trailing-cr --ignore-trailing-space ../$norm2 $fixed_out_name | head -c 200)
      # Check that output file was produced and was correct.
      if [[ "$result" != '' || ! -f $fixed_out_name ]]; then 
         echo -e "         [\033[31mwrong\033[0m] Test $i:"
         echo "           " $result
         did_fail="true"
      fi;
   fi;
done;
if [ "$did_fail" = "false" ] ; then
   echo -e "      Done [\033[92mPASS\033[0m]\n"
else
   echo -e "      Done [\033[31mFAIL\033[0m]\n"
fi
cd ../
rm -r tmp/
