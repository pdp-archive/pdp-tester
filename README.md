## ΠΔΠ-tester: Έλεγχος προγραμμάτων για τον Πανελλήνιο Διαγωνισμό Πληροφορικής

Σε αυτό το παράδειγμα θα δούμε πώς μπορούμε να τρέξουμε τα testcases για το πρόβλημα astrolavos του ΠΔΠ 30. Ξεκινάμε κατεβάζοντας τον tester:

```
git clone https://github.com/pdp-archive/pdp-tester.git
```


Επειτα στον φάκελο με τον κώδικα σας (πχ "my_astrolavos.cc" -- μπορείτε να κατεβάσετε μία λύση από [εδώ](https://github.com/pdp-archive/pdp-archive.github.io/blob/master/_includes/source_code/code/30-PDP/astrolavos/astrolavos_efficient.cc)), τον κάνετε compile:

```
g++ my_astrolavos.cc
```

Και αν δεν υπάρχουν λάθη δημιουργεί ένα αρχείο a.exe (ή a.out ή κάτι άλλο). Για να τρέξετε όλα τα testcases τρέχετε:

```
bash pdptester 30-astrolavos a.out
```

Αν θέλουμε να τρέξουμε μόνο τα testcases 1,3,5,6,7,9, μπορούμε να το τρέξουμε το εξής (προσοχή δεν υπάρχουν κενά μεταξύ των αριθμών):

```
bash pdptester 30-astrolavos a.out --cases 1,3,5-7,9
```

Ο προκαθορισμένος χρονικός περιορισμός είναι 1s. Μπορείτε να το αυξήσετε ως εξής:

```
bash pdptester 30-astrolavos a.out --time_limit 2
```

