SELECT H.hacker_id,H.name FROM HACKERS H 
JOIN SUBMISSIONS S ON H.hacker_id=S.hacker_id 
JOIN CHALLENGES C ON S.challenge_id=C.challenge_id 
JOIN DIFFICULTY D ON C.difficulty_level=D.difficulty_level
WHERE S.score=D.score group by H.hacker_id,H.name
HAVING COUNT(S.challenge_id)>1 
ORDER BY COUNT(S.challenge_id) DESC,H.hacker_id;

SELECT h.hacker_id, h.name FROM Hackers h
INNER JOIN Submissions s ON (h.hacker_id = s.hacker_id)
INNER JOIN Challenges c ON (s.challenge_id = c.challenge_id)
INNER JOIN Difficulty d ON (c.difficulty_level = d.difficulty_level)
WHERE s.score = d.score
GROUP BY h.hacker_id, h.name
HAVING count(h.hacker_id) > 1
ORDER BY count(h.hacker_id) DESC, h.hacker_id ASC

SELECT Challenges.hacker_id, Hackers.name, COUNT(Challenges.challenge_id) AS challenges
FROM Hackers
JOIN Challenges on Hackers.hacker_id = Challenges.hacker_id
GROUP BY 1, 2
HAVING 
    -- count maximum number of challenges created
    challenges IN 
    (SELECT MAX(chal_count) FROM
    (SELECT COUNT(challenge_id) AS chal_count FROM Challenges
    GROUP BY hacker_id) AS t3)

    OR 
    -- One student created the same number of challenges 
    challenges IN
    (SELECT chal_count FROM
    (SELECT COUNT(challenge_id) AS chal_count FROM Challenges
    GROUP BY hacker_id) AS t4 
    GROUP BY 1 HAVING COUNT(chal_count) = 1)

ORDER BY 3 DESC, 1;