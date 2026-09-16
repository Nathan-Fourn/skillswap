-- =====================================================================
-- SkillSwap - schéma de la base
-- Exécuté automatiquement au premier démarrage du conteneur MySQL.
-- Utilisé à partir de la séance 2 (en séance 1, les données sont
-- encore dans un tableau PHP figé).
-- =====================================================================

-- Remarque : la table des sessions de mentorat s'appelle
-- `session_mentorat` et non `session`. SESSION est un mot-clé MySQL :
-- on évite de s'exposer à des erreurs de syntaxe obscures.

-- Le jeu de caractères du client est forcé ici : sans cela, un client
-- configuré en latin1 stocke les accents en double encodage
-- (« Rédaction » devient « RÃ©daction ») et le mal n'est visible qu'à l'affichage.
SET NAMES utf8mb4;

CREATE TABLE categorie (
    id      INT AUTO_INCREMENT PRIMARY KEY,
    libelle VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE collaborateur (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    nom           VARCHAR(80)  NOT NULL,
    prenom        VARCHAR(80)  NOT NULL,
    email         VARCHAR(180) NOT NULL UNIQUE,
    mot_de_passe  VARCHAR(255) NOT NULL,
    role          ENUM('ROLE_USER','ROLE_ADMIN') NOT NULL DEFAULT 'ROLE_USER',
    service       VARCHAR(80)  NOT NULL,
    date_arrivee  DATE         NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE competence (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    libelle      VARCHAR(120) NOT NULL UNIQUE,
    description  TEXT,
    categorie_id INT NOT NULL,
    CONSTRAINT fk_competence_categorie
        FOREIGN KEY (categorie_id) REFERENCES categorie(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table de liaison PORTEUSE D'ATTRIBUT : le niveau de maîtrise.
-- C'est le morceau de choix du modèle - on y reviendra en séance 7.
CREATE TABLE maitrise (
    collaborateur_id INT NOT NULL,
    competence_id    INT NOT NULL,
    niveau           TINYINT NOT NULL,
    PRIMARY KEY (collaborateur_id, competence_id),
    CONSTRAINT fk_maitrise_collaborateur
        FOREIGN KEY (collaborateur_id) REFERENCES collaborateur(id) ON DELETE CASCADE,
    CONSTRAINT fk_maitrise_competence
        FOREIGN KEY (competence_id) REFERENCES competence(id) ON DELETE CASCADE,
    CONSTRAINT ck_maitrise_niveau CHECK (niveau BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE demande (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    demandeur_id   INT NOT NULL,
    competence_id  INT NOT NULL,
    description    TEXT,
    statut         ENUM('ouverte','pourvue','annulee') NOT NULL DEFAULT 'ouverte',
    date_creation  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_demande_demandeur
        FOREIGN KEY (demandeur_id) REFERENCES collaborateur(id),
    CONSTRAINT fk_demande_competence
        FOREIGN KEY (competence_id) REFERENCES competence(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Double relation vers collaborateur : le mentor ici, le demandeur via la demande.
CREATE TABLE session_mentorat (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    demande_id    INT NOT NULL,
    mentor_id     INT NOT NULL,
    date_prevue   DATETIME NOT NULL,
    duree_minutes INT NOT NULL DEFAULT 60,
    statut        ENUM('planifiee','terminee','annulee') NOT NULL DEFAULT 'planifiee',
    CONSTRAINT fk_session_demande
        FOREIGN KEY (demande_id) REFERENCES demande(id) ON DELETE CASCADE,
    CONSTRAINT fk_session_mentor
        FOREIGN KEY (mentor_id) REFERENCES collaborateur(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Un seul avis par session et par auteur : c'est la contrainte d'unicité
-- qui traduit la règle métier n°3.
CREATE TABLE avis (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    session_id  INT NOT NULL,
    auteur_id   INT NOT NULL,
    note        TINYINT NOT NULL,
    commentaire TEXT,
    date_avis   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_avis_session
        FOREIGN KEY (session_id) REFERENCES session_mentorat(id) ON DELETE CASCADE,
    CONSTRAINT fk_avis_auteur
        FOREIGN KEY (auteur_id) REFERENCES collaborateur(id),
    CONSTRAINT uq_avis_session_auteur UNIQUE (session_id, auteur_id),
    CONSTRAINT ck_avis_note CHECK (note BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
