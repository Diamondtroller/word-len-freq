# word-len-freq
Asamblera kursa papilduzdevums. Uzdevums bija uzrakstīt MASM programmu, kas:
* nolasa no diska teksta datnes saturu,
* sadala tekstu vārdos izmantojot programmas tekstā definētus atdalītājus (` `,`.`,`,`,`!`,CR,LF),
* saskaita cik daudz vārdu ir atbilstošajos vārdu garumos un izvada tabulu ar šo,
* izvada datnes saturu.
  
> [!WARNING]
> Šis kods tikai strādā ar failiem, kam ir 1 baita kodējums.

Assembly course optional assignment. The task was to write a MASM program, that:
* reads the contents of a text file from the disk,
* splits the text using delimiters defined in the program text (` `,`.`,`,`,`!`,CR,LF),
* counts the amounts of words corresponding to the word lenghts and outputs this in a table
* output the text file's content

> [!WARNING]
> This code only works on files with a 1 byte encoding.

# Palaist / Run
* Uzkompilēt un palaist programmu latviski:
```bat
ml /c /coff uzd_1.asm
link /subsystem:console uzd_1.obj
uzd_1.exe
```
* Compile and run the program in english:
```bat
ml /c /coff /D EN uzd_1.asm
link /subsystem:console uzd_1.obj
uzd_1.exe
```
