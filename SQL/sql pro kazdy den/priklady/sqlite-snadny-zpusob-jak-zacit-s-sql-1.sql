SELECT *
FROM ockovani
WHERE country IN ('Czechia', 'Israel', 'Slovakia', 'Sweden')
ORDER BY fully_vaccinated DESC
;
