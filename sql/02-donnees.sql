-- =====================================================================
-- SkillSwap - jeu de données de démonstration
-- Volume calibré pour que les listes soient lisibles à l'écran
-- tout en rendant les tris et filtres intéressants.
-- =====================================================================

-- Le jeu de caractères du client est forcé ici : sans cela, un client
-- configuré en latin1 stocke les accents en double encodage
-- (« Rédaction » devient « RÃ©daction ») et le mal n'est visible qu'à l'affichage.
SET NAMES utf8mb4;

INSERT INTO categorie (id, libelle) VALUES
  (1, 'Développement'),
  (2, 'Infrastructure'),
  (3, 'Données'),
  (4, 'Méthodes et gestion'),
  (5, 'Communication');

-- ATTENTION - mots de passe.
-- La colonne contient ici un PLACEHOLDER, pas un vrai hachage.
-- Aucun de ces comptes ne peut donc se connecter en l'état : c'est voulu.
-- En séance 4, vous générerez de vrais hachages avec password_hash()
-- et remplacerez ces valeurs. On ne stocke JAMAIS un mot de passe en clair.
INSERT INTO collaborateur (id, nom, prenom, email, mot_de_passe, role, service, date_arrivee) VALUES
  (1,  'Marchand', 'Camille', 'camille.marchand@skillswap.fr', 'A_REMPLACER', 'ROLE_ADMIN', 'DSI',            '2019-03-11'),
  (2,  'Fontaine', 'Ludovic', 'ludovic.fontaine@skillswap.fr', 'A_REMPLACER', 'ROLE_USER',  'Développement',  '2021-09-01'),
  (3,  'Nguyen',   'Thi',     'thi.nguyen@skillswap.fr',       'A_REMPLACER', 'ROLE_USER',  'Développement',  '2022-01-17'),
  (4,  'Boulanger','Sarah',   'sarah.boulanger@skillswap.fr',  'A_REMPLACER', 'ROLE_USER',  'Infrastructure', '2018-06-04'),
  (5,  'Diallo',   'Moussa',  'moussa.diallo@skillswap.fr',    'A_REMPLACER', 'ROLE_USER',  'Infrastructure', '2023-02-13'),
  (6,  'Lefevre',  'Antoine', 'antoine.lefevre@skillswap.fr',  'A_REMPLACER', 'ROLE_USER',  'Données',        '2020-11-23'),
  (7,  'Perrin',   'Elodie',  'elodie.perrin@skillswap.fr',    'A_REMPLACER', 'ROLE_USER',  'Données',        '2024-09-02'),
  (8,  'Chevalier','Hugo',    'hugo.chevalier@skillswap.fr',   'A_REMPLACER', 'ROLE_USER',  'Développement',  '2025-01-06'),
  (9,  'Roux',     'Nadia',   'nadia.roux@skillswap.fr',       'A_REMPLACER', 'ROLE_USER',  'Projet',         '2017-04-18'),
  (10, 'Gauthier', 'Paul',    'paul.gauthier@skillswap.fr',    'A_REMPLACER', 'ROLE_USER',  'Projet',         '2025-09-01');

INSERT INTO competence (id, libelle, description, categorie_id) VALUES
  (1,  'PHP 8',            'Syntaxe moderne, typage, programmation objet',        1),
  (2,  'Symfony',          'Framework PHP : routing, Twig, Doctrine',             1),
  (3,  'JavaScript',       'Manipulation du DOM et appels asynchrones',           1),
  (4,  'Git',              'Branches, fusion, résolution de conflits',            1),
  (5,  'Docker',           'Conteneurs, images, Compose',                         2),
  (6,  'Linux',            'Ligne de commande, droits, services',                 2),
  (7,  'Réseau TCP/IP',    'Adressage, routage, diagnostic',                      2),
  (8,  'SQL',              'Requêtes, jointures, index',                          3),
  (9,  'MongoDB',          'Modèle documentaire et agrégations',                  3),
  (10, 'Power BI',         'Tableaux de bord et visualisation',                   3),
  (11, 'Scrum',            'Rituels, rôles, backlog',                             4),
  (12, 'Gestion de projet','Planification, budget, suivi des risques',            4),
  (13, 'Prise de parole',  'Présenter devant un groupe sans transpirer',          5),
  (14, 'Rédaction technique','Documentation claire et utile',                     5);

-- Deux cas limites volontaires ci-dessous.
-- Le collaborateur 10 (Paul Gauthier, arrivé en septembre 2025) n'apparaît
-- dans AUCUNE ligne : il n'a encore rien déclaré.
-- Et la compétence 14 (Rédaction technique) n'apparaît volontairement
-- dans AUCUNE ligne ci-dessous. Personne ne la maîtrise.
-- C'est le cas limite qui rend visible la différence entre JOIN et LEFT JOIN.
INSERT INTO maitrise (collaborateur_id, competence_id, niveau) VALUES
  (1, 12, 5), (1, 11, 4), (1, 4, 4),
  (2, 1, 5),  (2, 2, 4),  (2, 4, 5), (2, 8, 3),
  (3, 1, 4),  (3, 3, 5),  (3, 4, 3),
  (4, 5, 5),  (4, 6, 5),  (4, 7, 4),
  (5, 6, 3),  (5, 7, 3),
  (6, 8, 5),  (6, 9, 4),  (6, 10, 3),
  (7, 8, 3),  (7, 10, 4),
  (8, 3, 2),  (8, 4, 2),
  (9, 11, 5), (9, 12, 4), (9, 13, 5);

INSERT INTO demande (id, demandeur_id, competence_id, description, statut, date_creation) VALUES
  (1, 8,  1,  'Je débute en PHP, j''aimerais comprendre la programmation objet.', 'pourvue',  '2026-09-02 09:14:00'),
  (2, 8,  5,  'Docker me fait peur, besoin d''une mise en route.',                'pourvue',  '2026-09-02 09:20:00'),
  (3, 10, 4,  'Je fais toujours mes commits n''importe comment.',                 'ouverte',  '2026-09-03 14:02:00'),
  (4, 7,  9,  'Curieuse de voir autre chose que du relationnel.',                 'ouverte',  '2026-09-04 11:37:00'),
  (5, 5,  8,  'Mes jointures ne donnent jamais ce que j''attends.',               'pourvue',  '2026-09-05 08:55:00'),
  (6, 3,  13, 'Je dois présenter en comité le mois prochain.',                    'ouverte',  '2026-09-08 16:10:00'),
  (7, 2,  10, 'On me demande des tableaux de bord, je sèche.',                    'annulee',  '2026-09-09 10:25:00'),
  (8, 6,  2,  'Je connais PHP mais pas le framework.',                            'pourvue',  '2026-09-10 13:48:00');

INSERT INTO session_mentorat (id, demande_id, mentor_id, date_prevue, duree_minutes, statut) VALUES
  (1, 1, 2, '2026-09-08 10:00:00', 90, 'terminee'),
  (2, 2, 4, '2026-09-09 14:00:00', 60, 'terminee'),
  (3, 5, 6, '2026-09-11 09:30:00', 60, 'terminee'),
  (4, 8, 2, '2026-09-16 15:00:00', 120,'planifiee'),
  (5, 1, 3, '2026-09-18 11:00:00', 60, 'planifiee');

-- Seules les sessions TERMINÉES portent un avis : c'est la règle métier n°2.
INSERT INTO avis (session_id, auteur_id, note, commentaire, date_avis) VALUES
  (1, 8, 5, 'Très clair, les exemples m''ont débloqué.',            '2026-09-08 12:05:00'),
  (2, 8, 4, 'Bonne session, un peu rapide sur les volumes.',        '2026-09-09 15:30:00'),
  (3, 5, 5, 'Enfin compris la différence entre les jointures.',     '2026-09-11 11:00:00'),
  (1, 2, 4, 'Bon échange, le demandeur était très préparé.',        '2026-09-08 12:20:00');
