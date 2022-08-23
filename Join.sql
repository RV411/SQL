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