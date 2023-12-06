\set ncli 15000
\set nfourn 10000
\set ncmd 600000
\set cli_id random_gaussian(1,:ncli,10)
\set year random_exponential(2005,2019,10)
\set reg_id random_gaussian(0,4,2.5)
\set cout random_gaussian(900,1000,8)
\set qte random_gaussian(1,9999,10)
\set solde random_gaussian(400,500,8)

-- quals:
-- clients.solde
-- commandes.client_id
-- commande.date_commande
-- pieces_fournisseurs.cout
-- pieces_fournisseurs.quantite_disponible
-- region.nom_region (should not be indexed)
-- pays.region_id (should not be indexed)


-- simple query without qual
SELECT * FROM contacts;

-- just a join
SELECT * FROM clients cl JOIN contacts co ON co.contact_id = cl.contact_id;

-- join and a qual
SELECT co.nom FROM clients cl JOIN contacts co ON co.contact_id = cl.contact_id WHERE cl.solde > :solde;

-- one qual
SELECT numero_commande, etat_commande FROM commandes WHERE client_id = :cli_id;

SELECT pg_sleep(3);

-- multiple quals, best order in attnum order
SELECT numero_commande, etat_commande FROM commandes WHERE client_id = :cli_id AND date_commande BETWEEN (:year || '-01-01')::date AND (:year || '-12-21')::date;

-- same quals, but different operator
SELECT numero_commande, etat_commande FROM commandes WHERE client_id = :cli_id AND date_commande >= (:year || '-01-01')::date;

-- multiple quals but with functionnal qual
SELECT numero_commande, etat_commande FROM commandes WHERE client_id = :cli_id AND EXTRACT('year' FROM date_commande) = :year;

-- quals previously used, in a different query
SELECT COUNT(*) FROM commandes WHERE date_commande BETWEEN (:year || '-01-01')::date AND (:year || '-12-21')::date;

-- quals previously used, but with a join
SELECT count(*) FROM commandes cmd JOIN lignes_commandes lc ON lc.numero_commande = cmd.numero_commande WHERE cmd.client_id = :cli_id AND date_commande BETWEEN (:year || '-01-01')::date AND (:year || '-12-21')::date;

-- 1 previous used qual and a join
SELECT count(*) FROM commandes cmd JOIN lignes_commandes lc ON lc.numero_commande = cmd.numero_commande WHERE cmd.client_id = :cli_id;

SELECT pg_sleep(3);

-- two quals, one needing a specific (but hardcoded) opclass
SELECT COUNT(*) FROM commandes WHERE client_id = :cli_id AND priorite_commande LIKE '3-%';

-- quals that cannot be optimized by any AM
SELECT COUNT(*) FROM commandes WHERE client_id != :cli_id;
SELECT COUNT(*) FROM commandes WHERE client_id != :cli_id AND priorite_commande LIKE '%3-%';

-- other quals, still one needing a specific (but hardcoded) opclass
SELECT COUNT(*) FROM commandes WHERE date_commande BETWEEN (:year || '-01-01')::date AND (:year || '-12-21')::date AND priorite_commande LIKE '3-%';

-- many quals and join, again one qual needing a specific (but hardcoded) opclass
-- not needed SELECT COUNT(*) FROM commandes com JOIN clients cli ON cli.client_id = com.client_id JOIN contacts con ON con.contact_id = cli.contact_id JOIN pays p ON p.code_pays = con.code_pays JOIN regions r ON r.region_id = p.region_id WHERE date_commande BETWEEN (:year || '-01-01')::date AND (:year || '-12-21')::date AND priorite_commande LIKE '3-%' AND r.region_id = :reg_id;

-- a join, two quals but the SELECT part will be jumbled
SELECT con.nom || ' (' || code_pays || ' )' FROM clients cli JOIN contacts con ON con.contact_id = cli.contact_id WHERE solde > :solde;

SELECT pg_sleep(3);

-- multiple joins, one previsouly used qual
SELECT COUNT(*) FROM pays p JOIN contacts con ON con.code_pays = p.code_pays JOIN clients cli ON cli.contact_id = con.contact_id AND p.region_id = :reg_id;

-- multiple join and no qual
SELECT COUNT(*) FROM pays p JOIN contacts con ON con.code_pays = p.code_pays JOIN clients cli ON cli.contact_id = con.contact_id;

SELECT pg_sleep(3);

-- qual, but useless index
SELECT region_id FROM regions WHERE nom_region = 'Asie';

-- qual and join, but useless index
SELECT nom FROM contacts c JOIN pays p ON p.code_pays = c.code_pays WHERE nom_pays = 'FRANCE';

-- one qual, future queries will need order different from attnum
SELECT COUNT(*) FROM pieces_fournisseurs WHERE cout_piece >= :cout;

SELECT pg_sleep(3);

-- two qual, using previous one
SELECT COUNT(*) FROM pieces_fournisseurs WHERE quantite_disponible < :qte AND cout_piece >= :cout;

-- ********
-- Level 2
-- *********

-- 3 quals
SELECT COUNT(*) FROM commandes cmd JOIN clients cl ON cl.client_id = cmd.client_id WHERE cl.solde > 0 AND Cl.client_id = :cli_id AND  date_commande BETWEEN (:year || '-01-01')::date AND (:year || '-12-21')::date;

-- wait, avoid to burn my computer
SELECT pg_sleep(30);
