# ShiftManager
A series of tools for managing shifts

## `splitCalendar.m`
A first version of a calendar splitter.

The splitter parses the calendar released by the OP responsible and creates a `.csv` file for a given shifter with the list of shifts.
The `.csv` file has the format requested by google calendar for import.
The parser takes into account account notes and comments in the original spreadsheet; nevertheless, a shifter should always cross-check the information saved in the `.csv` file against the original spreadsheet.

## Per importare il `.csv` file
Si consiglia di importare i turni in un calendario dedicato.
Questo permette di cancellare e ri-creare il calendario dedicato, partendo da una nuova versione del `.csv` file.

### Importazione
* apri Google calendar, porta il cursore sul menù impostazioni (simbolo della rotella) e premi su "Impostazioni";
* dal menù a sinistra, premi su "Importazione ed esportazione";
* seleziona il file `.csv` da importare e seleziona il calendario sul quale importare i turni;
* premi il tasto "Importa".

### Creazione calendario dedicato
* apri Google calendar, porta il cursore sul menù impostazioni (simbolo della rotella) e premi su "Impostazioni";
* dal menù a sinistra, premi su "Crea nuovo calendario" (dalla sezione "Aggiungi calendario");
* immetti nome (per es. "turni"), descrizione (per es., "turni automaticamente importati da spreadsheet") e gli altri parameteri, a seconda delle necessità;
* premi il tasto "Crea calendario".
