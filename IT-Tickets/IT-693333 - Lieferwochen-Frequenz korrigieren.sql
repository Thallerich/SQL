WITH KalenderKorrektur AS (
  SELECT N'32-wöchentlich 1. Woche' AS KalenderBez,
    Lieferwochen = N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 20),
    LieferwochenFJ = REPLICATE(N'B', 12) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 8),
    LieferwochenFJ53 = REPLICATE(N'B', 11) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 9),
    Frequenz = 32,
    StartWoche = 1,
    StartWocheFJ = 13,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 2. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 1) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 19),
    LieferwochenFJ = REPLICATE(N'B', 13) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 7),
    LieferwochenFJ53 = REPLICATE(N'B', 12) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 8),
    Frequenz = 32,
    StartWoche = 2,
    StartWocheFJ = 14,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 3. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 2) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 18),
    LieferwochenFJ = REPLICATE(N'B', 14) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 6),
    LieferwochenFJ53 = REPLICATE(N'B', 13) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 5),
    Frequenz = 32,
    StartWoche = 3,
    StartWocheFJ = 15,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 4. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 3) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 17),
    LieferwochenFJ = REPLICATE(N'B', 15) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 5),
    LieferwochenFJ53 = REPLICATE(N'B', 14) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 6),
    Frequenz = 32,
    StartWoche = 4,
    StartWocheFJ = 16,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 5. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 4) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 16),
    LieferwochenFJ = REPLICATE(N'B', 16) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 4),
    LieferwochenFJ53 = REPLICATE(N'B', 15) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 5),
    Frequenz = 32,
    StartWoche = 5,
    StartWocheFJ = 17,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 6. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 5) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 15),
    LieferwochenFJ = REPLICATE(N'B', 17) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 3),
    LieferwochenFJ53 = REPLICATE(N'B', 16) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 4),
    Frequenz = 32,
    StartWoche = 6,
    StartWocheFJ = 18,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 7. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 6) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 14),
    LieferwochenFJ = REPLICATE(N'B', 18) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 2),
    LieferwochenFJ53 = REPLICATE(N'B', 17) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 3),
    Frequenz = 32,
    StartWoche = 7,
    StartWocheFJ = 19,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 8. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 7) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 13),
    LieferwochenFJ = REPLICATE(N'B', 19) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 1),
    LieferwochenFJ53 = REPLICATE(N'B', 18) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 2),
    Frequenz = 32,
    StartWoche = 8,
    StartWocheFJ = 20,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 9. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 8) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 12),
    LieferwochenFJ = REPLICATE(N'B', 20) + N'X' + REPLICATE(N'B', 31) + N'X',
    LieferwochenFJ53 = REPLICATE(N'B', 19) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 1),
    Frequenz = 32,
    StartWoche = 9,
    StartWocheFJ = 21,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 10. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 9) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 11),
    LieferwochenFJ = REPLICATE(N'B', 21) + N'X' + REPLICATE(N'B', 31),
    LieferwochenFJ53 = REPLICATE(N'B', 20) + N'X' + REPLICATE(N'B', 31) + N'X',
    Frequenz = 32,
    StartWoche = 10,
    StartWocheFJ = 22,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 11. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 10) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 10),
    LieferwochenFJ = REPLICATE(N'B', 22) + N'X' + REPLICATE(N'B', 30),
    LieferwochenFJ53 = REPLICATE(N'B', 21) + N'X' + REPLICATE(N'B', 31),
    Frequenz = 32,
    StartWoche = 11,
    StartWocheFJ = 23,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 12. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 11) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 9),
    LieferwochenFJ = REPLICATE(N'B', 23) + N'X' + REPLICATE(N'B', 29),
    LieferwochenFJ53 = REPLICATE(N'B', 22) + N'X' + REPLICATE(N'B', 30),
    Frequenz = 32,
    StartWoche = 12,
    StartWocheFJ = 24,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 13. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 12) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 8),
    LieferwochenFJ = REPLICATE(N'B', 24) + N'X' + REPLICATE(N'B', 28),
    LieferwochenFJ53 = REPLICATE(N'B', 23) + N'X' + REPLICATE(N'B', 29),
    Frequenz = 32,
    StartWoche = 13,
    StartWocheFJ = 25,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 14. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 13) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 7),
    LieferwochenFJ = REPLICATE(N'B', 25) + N'X' + REPLICATE(N'B', 27),
    LieferwochenFJ53 = REPLICATE(N'B', 24) + N'X' + REPLICATE(N'B', 26),
    Frequenz = 32,
    StartWoche = 14,
    StartWocheFJ = 26,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 15. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 14) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 6),
    LieferwochenFJ = REPLICATE(N'B', 26) + N'X' + REPLICATE(N'B', 26),
    LieferwochenFJ53 = REPLICATE(N'B', 25) + N'X' + REPLICATE(N'B', 25),
    Frequenz = 32,
    StartWoche = 15,
    StartWocheFJ = 27,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 16. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 15) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 5),
    LieferwochenFJ = REPLICATE(N'B', 27) + N'X' + REPLICATE(N'B', 25),
    LieferwochenFJ53 = REPLICATE(N'B', 26) + N'X' + REPLICATE(N'B', 24),
    Frequenz = 32,
    StartWoche = 16,
    StartWocheFJ = 28,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 17. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 16) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 4),
    LieferwochenFJ = REPLICATE(N'B', 28) + N'X' + REPLICATE(N'B', 24),
    LieferwochenFJ53 = REPLICATE(N'B', 27) + N'X' + REPLICATE(N'B', 23),
    Frequenz = 32,
    StartWoche = 17,
    StartWocheFJ = 29,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 18. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 17) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 3),
    LieferwochenFJ = REPLICATE(N'B', 29) + N'X' + REPLICATE(N'B', 23),
    LieferwochenFJ53 = REPLICATE(N'B', 28) + N'X' + REPLICATE(N'B', 22),
    Frequenz = 32,
    StartWoche = 18,
    StartWocheFJ = 30,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 19. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 18) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 2),
    LieferwochenFJ = REPLICATE(N'B', 30) + N'X' + REPLICATE(N'B', 22),
    LieferwochenFJ53 = REPLICATE(N'B', 29) + N'X' + REPLICATE(N'B', 21),
    Frequenz = 32,
    StartWoche = 19,
    StartWocheFJ = 31,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 20. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 19) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 1),
    LieferwochenFJ = REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 21),
    LieferwochenFJ53 = REPLICATE(N'B', 30) + N'X' + REPLICATE(N'B', 20),
    Frequenz = 32,
    StartWoche = 20,
    StartWocheFJ = 32,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 21. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 20) + N'X' + REPLICATE(N'B', 31) + N'X',
    LieferwochenFJ = N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 20),
    LieferwochenFJ53 = REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 20),
    Frequenz = 32,
    StartWoche = 21,
    StartWocheFJ = 1,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 22. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 21) + N'X' + REPLICATE(N'B', 31),
    LieferwochenFJ = REPLICATE(N'B', 1) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 19),
    LieferwochenFJ53 = N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 19),
    Frequenz = 32,
    StartWoche = 22,
    StartWocheFJ = 2,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 23. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 22) + N'X' + REPLICATE(N'B', 30),
    LieferwochenFJ = REPLICATE(N'B', 2) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 18),
    LieferwochenFJ53 = REPLICATE(N'B', 1) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 19),
    Frequenz = 32,
    StartWoche = 23,
    StartWocheFJ = 3,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 24. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 23) + N'X' + REPLICATE(N'B', 29),
    LieferwochenFJ = REPLICATE(N'B', 3) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 17),
    LieferwochenFJ53 = REPLICATE(N'B', 2) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 18),
    Frequenz = 32,
    StartWoche = 24,
    StartWocheFJ = 4,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 25. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 24) + N'X' + REPLICATE(N'B', 28),
    LieferwochenFJ = REPLICATE(N'B', 4) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 16),
    LieferwochenFJ53 = REPLICATE(N'B', 3) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 17),
    Frequenz = 32,
    StartWoche = 25,
    StartWocheFJ = 5,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 26. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 25) + N'X' + REPLICATE(N'B', 27),
    LieferwochenFJ = REPLICATE(N'B', 5) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 15),
    LieferwochenFJ53 = REPLICATE(N'B', 4) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 16),
    Frequenz = 32,
    StartWoche = 26,
    StartWocheFJ = 6,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 27. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 26) + N'X' + REPLICATE(N'B', 26),
    LieferwochenFJ = REPLICATE(N'B', 6) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 14),
    LieferwochenFJ53 = REPLICATE(N'B', 5) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 15),
    Frequenz = 32,
    StartWoche = 27,
    StartWocheFJ = 7,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 28. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 27) + N'X' + REPLICATE(N'B', 25),
    LieferwochenFJ = REPLICATE(N'B', 7) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 13),
    LieferwochenFJ53 = REPLICATE(N'B', 6) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 14),
    Frequenz = 32,
    StartWoche = 28,
    StartWocheFJ = 8,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 29. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 28) + N'X' + REPLICATE(N'B', 24),
    LieferwochenFJ = REPLICATE(N'B', 8) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 12),
    LieferwochenFJ53 = REPLICATE(N'B', 7) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 13),
    Frequenz = 32,
    StartWoche = 29,
    StartWocheFJ = 9,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''

  UNION

  SELECT N'32-wöchentlich 30. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 29) + N'X' + REPLICATE(N'B', 23),
    LieferwochenFJ = REPLICATE(N'B', 9) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 11),
    LieferwochenFJ53 = REPLICATE(N'B', 8) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 12),
    Frequenz = 32,
    StartWoche = 30,
    StartWocheFJ = 10,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''
    
  UNION

  SELECT N'32-wöchentlich 31. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 30) + N'X' + REPLICATE(N'B', 22),
    LieferwochenFJ = REPLICATE(N'B', 10) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 10),
    LieferwochenFJ53 = REPLICATE(N'B', 9) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 11),
    Frequenz = 32,
    StartWoche = 31,
    StartWocheFJ = 11,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''
    
  UNION

  SELECT N'32-wöchentlich 32. Woche' AS KalenderBez,
    Lieferwochen = REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 21),
    LieferwochenFJ = REPLICATE(N'B', 11) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 9),
    LieferwochenFJ53 = REPLICATE(N'B', 10) + N'X' + REPLICATE(N'B', 31) + N'X' + REPLICATE(N'B', 10),
    Frequenz = 32,
    StartWoche = 32,
    StartWocheFJ = 12,
    AnzAnfahrt = 0.25,
    FreqID = 100,
    LieferWochenFeiertag = N''
)
INSERT INTO Kalender (KalenderBez, KalenderBez1, KalenderBez2, KalenderBez3, KalenderBez4, KalenderBez5, KalenderBez6, KalenderBez7, KalenderBez8, KalenderBez9, KalenderBezA, Lieferwochen, LieferwochenFJ, LieferwochenFJ53, Frequenz, StartWoche, StartWocheFJ, VSA, KdArti, VsaLeas, AnzAnfahrt, FreqID, LieferWochenFeiertag)
SELECT KalenderBez, KalenderBez, KalenderBez, KalenderBez, KalenderBez, KalenderBez, KalenderBez, KalenderBez, KalenderBez, KalenderBez, KalenderBez, Lieferwochen, LieferwochenFJ, LieferwochenFJ53, Frequenz, StartWoche, StartWocheFJ, CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), AnzAnfahrt, FreqID, LieferwochenFeiertag
FROM KalenderKorrektur;