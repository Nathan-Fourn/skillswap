<?php
/**
 * Page de vérification de l'environnement SkillSwap.
 *
 * Elle ne fait pas partie de l'application : elle sert à constater, d'un
 * coup d'œil, que tout ce dont le module aura besoin est en place.
 * Vous la remplacerez par votre propre page d'accueil à l'exercice B1.
 */

// --- Les extensions dont le module se sert, séance par séance ---------
// Attention : cette page est exécutée par le SERVEUR WEB. Or PHP a deux
// modes d'exécution, et ils ne chargent pas exactement les mêmes extensions.
// « readline » (la saisie au clavier de l'exercice A3) n'existe QUE en ligne
// de commande : il est normal qu'elle n'apparaisse pas ici. On la vérifie
// avec « docker compose exec web php -m ».
$extensions = [
    'mbstring'  => 'Chaînes accentuées — mb_strlen, mb_substr (séance 1)',
    'pdo_mysql' => 'Accès à la base de données (séance 2)',
    'intl'      => 'Exigée par Symfony (séance 6)',
    'zip'       => 'Utilisée par Composer (séances 3 et 6)',
];

$manquantes = array_filter(
    array_keys($extensions),
    fn(string $nom): bool => !extension_loaded($nom)
);

// --- La base répond-elle ? --------------------------------------------
// Depuis le conteneur, la base s'appelle « db » sur le port 3306.
// Ni localhost, ni 13306 : ce port-là ne sert qu'aux outils de votre poste.
$baseEtat   = 'ko';
$baseDetail = '';
$nbTables   = 0;

try {
    $pdo = new PDO(
        'mysql:host=db;port=3306;dbname=skillswap;charset=utf8mb4',
        'skillswap',
        'skillswap',
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
    $nbTables   = (int) $pdo->query('SELECT COUNT(*) FROM information_schema.tables
                                     WHERE table_schema = "skillswap"')->fetchColumn();
    $baseEtat   = $nbTables > 0 ? 'ok' : 'attente';
    $baseDetail = $nbTables > 0
        ? $nbTables . ' tables présentes'
        : 'connectée, mais aucune table — voir le README';
} catch (PDOException $e) {
    $baseDetail = $e->getMessage();
}

$toutEstPret = $manquantes === [] && $baseEtat === 'ok';
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SkillSwap — vérification de l'environnement</title>
    <style>
        :root { color-scheme: light; }
        body {
            margin: 0; padding: 2.5rem 1.5rem;
            font-family: "Segoe UI", system-ui, sans-serif;
            background: #f4f6f7; color: #08313A; line-height: 1.5;
        }
        main { max-width: 46rem; margin: 0 auto; }
        h1 { margin: 0 0 .25rem; font-size: 1.9rem; }
        .sous-titre { margin: 0 0 1.75rem; color: #5a6a70; }
        .verdict {
            padding: 1rem 1.25rem; border-radius: 6px; margin-bottom: 1.75rem;
            font-weight: 600; border-left: 6px solid;
        }
        .verdict-ok { background: #e6f7f1; border-color: #00A896; }
        .verdict-ko { background: #fdecea; border-color: #c0392b; }
        table { width: 100%; border-collapse: collapse; background: #fff;
                border-radius: 6px; overflow: hidden; margin-bottom: 1.5rem; }
        caption { text-align: left; font-weight: 600; padding: .6rem 0; }
        th, td { padding: .6rem .9rem; text-align: left; border-bottom: 1px solid #e3e8ea; }
        th { background: #08313A; color: #fff; font-weight: 600; }
        tr:last-child td { border-bottom: none; }
        td.etat { width: 7rem; font-weight: 600; }
        .ok { color: #00856f; }
        .ko { color: #c0392b; }
        code { background: #eceff1; padding: .1rem .35rem; border-radius: 3px;
               font-family: Consolas, "Courier New", monospace; }
        .note { background: #fff8e6; border-left: 6px solid #e8b931;
                padding: .85rem 1.1rem; border-radius: 6px; margin: -.5rem 0 1.5rem; }
        footer { color: #5a6a70; font-size: .9rem; border-top: 1px solid #dde3e5;
                 padding-top: 1rem; }
    </style>
</head>
<body>
<main>

    <h1>SkillSwap</h1>
    <p class="sous-titre">Page de vérification de l'environnement — R3.01</p>

    <?php if ($toutEstPret): ?>
        <p class="verdict verdict-ok">
            Tout est prêt. Vous pouvez commencer le TP.
        </p>
    <?php else: ?>
        <p class="verdict verdict-ko">
            Quelque chose manque — voyez les lignes en rouge ci-dessous,
            puis la section « Dépannage » du README.
        </p>
    <?php endif; ?>

    <table>
        <caption>Le serveur</caption>
        <tr><th>Point</th><th>Valeur</th></tr>
        <tr>
            <td>Version de PHP</td>
            <td><code><?= PHP_VERSION ?></code> — la même pour toute la classe</td>
        </tr>
        <tr>
            <td>Racine web</td>
            <td><code><?= htmlspecialchars($_SERVER['DOCUMENT_ROOT']) ?></code></td>
        </tr>
        <tr>
            <td>Date du serveur</td>
            <td><?= date('d/m/Y H:i') ?></td>
        </tr>
    </table>

    <table>
        <caption>Les extensions PHP — côté serveur web</caption>
        <tr><th>Extension</th><th>État</th><th>À quoi elle sert</th></tr>
        <?php foreach ($extensions as $nom => $usage): ?>
            <?php $presente = extension_loaded($nom); ?>
            <tr>
                <td><code><?= $nom ?></code></td>
                <td class="etat <?= $presente ? 'ok' : 'ko' ?>">
                    <?= $presente ? 'présente' : 'MANQUANTE' ?>
                </td>
                <td><?= $usage ?></td>
            </tr>
        <?php endforeach; ?>
    </table>

    <p class="note">
        L'extension <code>readline</code> (la saisie au clavier de l'exercice&nbsp;A3)
        n'apparaît pas ci-dessus, et c'est normal : elle n'existe qu'en
        <strong>ligne de commande</strong>, pas côté serveur web. Pour la vérifier :
        <code>docker compose exec web php -m</code>.
    </p>

    <table>
        <caption>La base de données</caption>
        <tr><th>Point</th><th>État</th><th>Détail</th></tr>
        <tr>
            <td>Connexion à <code>db:3306</code></td>
            <td class="etat <?= $baseEtat === 'ok' ? 'ok' : 'ko' ?>">
                <?= $baseEtat === 'ok' ? 'établie' : 'ÉCHEC' ?>
            </td>
            <td><?= htmlspecialchars($baseDetail) ?></td>
        </tr>
    </table>

    <footer>
        Cette page est jetable : vous la remplacez par votre page d'accueil à
        l'exercice&nbsp;B1. Les dossiers <code>cli/</code>, <code>inc/</code> et
        <code>data/</code> sont hors de la racine web — donc invisibles depuis
        un navigateur, et c'est voulu.
    </footer>

</main>
</body>
</html>
