import 'tr_entry.dart';

/// Layar awal, muat karier, karier baru, navigasi, beranda, skuad, pemain,
/// taktik.
const Map<String, Tr> screensAStrings = {
  // --- Layar awal ---
  'start.tagline': (
    en:
        'Manage a LaLiga or Hypermotion club, from the transfer window to the final whistle.',
    id:
        'Latih klub LaLiga atau Hypermotion, dari bursa transfer sampai peluit akhir.',
    fr:
        'Dirigez un club de LaLiga ou d\'Hypermotion, du mercato au coup de sifflet final.',
  ),
  'start.newCareer': (
    en: 'Start a new career',
    id: 'Mulai karier baru',
    fr: 'Nouvelle carrière',
  ),
  'start.allSaves': (
    en: 'View all saves',
    id: 'Lihat semua save',
    fr: 'Voir toutes les sauvegardes',
  ),
  'start.continue': (
    en: 'Continue career',
    id: 'Lanjutkan karier',
    fr: 'Reprendre la carrière',
  ),
  'start.openFailed': (
    en: 'Could not open the save: {error}',
    id: 'Save tidak bisa dibuka: {error}',
    fr: 'Impossible d\'ouvrir la sauvegarde : {error}',
  ),

  // --- Muat karier ---
  'load.title': (
    en: 'Load Career',
    id: 'Muat Karier',
    fr: 'Charger une carrière',
  ),
  'load.reload': (en: 'Reload', id: 'Muat ulang', fr: 'Actualiser'),
  'load.listFailed': (
    en: 'Could not read the save list: {error}',
    id: 'Gagal membaca daftar save: {error}',
    fr: 'Impossible de lire la liste des sauvegardes : {error}',
  ),
  'load.openFailed': (
    en: 'Could not load the save: {error}',
    id: 'Gagal memuat save: {error}',
    fr: 'Impossible de charger la sauvegarde : {error}',
  ),
  'load.deleteTitle': (
    en: 'Delete save?',
    id: 'Hapus save?',
    fr: 'Supprimer la sauvegarde ?',
  ),
  'load.slot': (en: 'Slot {n}', id: 'Slot {n}', fr: 'Emplacement {n}'),
  'load.deleteBody': (
    en: 'This save will be deleted permanently and cannot be restored.',
    id: 'Save ini akan dihapus permanen dan tidak bisa dikembalikan.',
    fr: 'Cette sauvegarde sera supprimée définitivement.',
  ),
  'load.deleted': (
    en: 'Save slot {n} deleted.',
    id: 'Save slot {n} berhasil dihapus.',
    fr: 'Emplacement {n} supprimé.',
  ),
  'load.deleteFailed': (
    en: 'Could not delete save slot {n}: {error}',
    id: 'Gagal menghapus save slot {n}: {error}',
    fr: 'Impossible de supprimer l\'emplacement {n} : {error}',
  ),
  'load.empty': (
    en: 'No saved careers yet.\nStart a new career from the main menu.',
    id: 'Belum ada karier yang tersimpan.\nBuat karier baru dari menu awal.',
    fr:
        'Aucune carrière sauvegardée.\nCommencez-en une depuis le menu principal.',
  ),
  'load.gameDate': (
    en: 'Game date: {date}',
    id: 'Tanggal game: {date}',
    fr: 'Date du jeu : {date}',
  ),
  'load.savedAt': (
    en: 'Saved: {date}',
    id: 'Disimpan: {date}',
    fr: 'Sauvegardé : {date}',
  ),
  'load.brokenTitle': (
    en: 'Save cannot be read',
    id: 'Save tidak dapat dibaca',
    fr: 'Sauvegarde illisible',
  ),
  'load.brokenBody': (
    en:
        'The save file exists but its data is corrupt or incomplete. Delete it to free this slot.',
    id:
        'File save ada tetapi datanya rusak atau belum lengkap. Hapus untuk mengosongkan slot ini.',
    fr:
        'Le fichier existe mais ses données sont corrompues ou incomplètes. Supprimez-le pour libérer l\'emplacement.',
  ),
  'load.brokenShort': (
    en: 'corrupt save',
    id: 'save rusak',
    fr: 'sauvegarde corrompue',
  ),
  'load.deleteTooltip': (
    en: 'Delete save',
    id: 'Hapus save',
    fr: 'Supprimer la sauvegarde',
  ),

  // --- Karier baru ---
  'newCareer.title': (
    en: 'New Career',
    id: 'Karier Baru',
    fr: 'Nouvelle carrière',
  ),
  'newCareer.confirm': (
    en: 'Start a career as manager {name} at {club}?',
    id: 'Mulai karier sebagai manajer {name} di {club}?',
    fr: 'Commencer une carrière d\'entraîneur ({name}) à {club} ?',
  ),
  'newCareer.start': (en: 'Start', id: 'Mulai', fr: 'Commencer'),
  'newCareer.failed': (
    en: 'Could not create the career: {error}',
    id: 'Gagal membuat karier: {error}',
    fr: 'Impossible de créer la carrière : {error}',
  ),
  'newCareer.slotsFull': (
    en: 'All save slots are taken (max {max} slots).',
    id: 'Semua slot save sudah terisi (maksimal {max} slot).',
    fr: 'Tous les emplacements sont occupés ({max} maximum).',
  ),
  'newCareer.manageSaves': (en: 'Manage Saves', id: 'Kelola Save', fr: 'Gérer'),
  'newCareer.building': (
    en: 'Building the world...',
    id: 'Membangun dunia...',
    fr: 'Création du monde...',
  ),
  'newCareer.askName': (
    en: 'What\'s your name, boss?',
    id: 'Siapa namamu, manajer?',
    fr: 'Quel est votre nom, coach ?',
  ),
  'newCareer.nameLabel': (
    en: 'Manager name',
    id: 'Nama manajer',
    fr: 'Nom de l\'entraîneur',
  ),
  'newCareer.next': (en: 'Next', id: 'Lanjut', fr: 'Suivant'),
  'newCareer.leaguesFailed': (
    en: 'Could not load leagues: {error}',
    id: 'Gagal memuat liga: {error}',
    fr: 'Impossible de charger les ligues : {error}',
  ),
  'newCareer.clubsFailed': (
    en: 'Could not load clubs: {error}',
    id: 'Gagal memuat klub: {error}',
    fr: 'Impossible de charger les clubs : {error}',
  ),
  'newCareer.pickLeague': (
    en: 'Choose a league',
    id: 'Pilih liga',
    fr: 'Choisissez une ligue',
  ),
  'newCareer.leagueInfo': (
    en: 'Tier {tier} · {teams} teams · Relegation {down}',
    id: 'Tier {tier} · {teams} tim · Degradasi {down}',
    fr: 'Niveau {tier} · {teams} équipes · Relégation {down}',
  ),
  'newCareer.promotion': (
    en: 'Promotion {n}',
    id: 'Promosi {n}',
    fr: 'Promotion {n}',
  ),
  'newCareer.reputation': (
    en: 'Reputation {n}',
    id: 'Reputasi {n}',
    fr: 'Réputation {n}',
  ),
  'newCareer.finances': (
    en: 'Balance {balance} · Transfers {transfer} · Wages {wage}/yr',
    id: 'Saldo {balance} · Transfer {transfer} · Gaji {wage}/th',
    fr: 'Solde {balance} · Transferts {transfer} · Salaires {wage}/an',
  ),

  // --- Navigasi ---
  'nav.home': (en: 'Home', id: 'Beranda', fr: 'Accueil'),
  'nav.squad': (en: 'Squad', id: 'Skuad', fr: 'Effectif'),
  'nav.fixtures': (en: 'Fixtures', id: 'Jadwal', fr: 'Calendrier'),
  'nav.transfer': (en: 'Transfers', id: 'Transfer', fr: 'Transferts'),
  'nav.inbox': (en: 'Inbox', id: 'Inbox', fr: 'Messages'),

  // --- Hari (1 = Senin, sama dengan DateTime.weekday) ---
  'weekday.1': (en: 'Monday', id: 'Senin', fr: 'Lundi'),
  'weekday.2': (en: 'Tuesday', id: 'Selasa', fr: 'Mardi'),
  'weekday.3': (en: 'Wednesday', id: 'Rabu', fr: 'Mercredi'),
  'weekday.4': (en: 'Thursday', id: 'Kamis', fr: 'Jeudi'),
  'weekday.5': (en: 'Friday', id: 'Jumat', fr: 'Vendredi'),
  'weekday.6': (en: 'Saturday', id: 'Sabtu', fr: 'Samedi'),
  'weekday.7': (en: 'Sunday', id: 'Minggu', fr: 'Dimanche'),

  // --- Beranda ---
  'dash.career': (en: 'Career', id: 'Karier', fr: 'Carrière'),
  'dash.season': (
    en: 'Season {season}',
    id: 'Musim {season}',
    fr: 'Saison {season}',
  ),
  'dash.toMenu': (
    en: 'Back to main menu',
    id: 'Kembali ke menu awal',
    fr: 'Retour au menu principal',
  ),
  'dash.leaguePos': (
    en: 'League position',
    id: 'Posisi liga',
    fr: 'Classement',
  ),
  'dash.ofTeams': (
    en: 'of {n} teams',
    id: 'dari {n} tim',
    fr: 'sur {n} équipes',
  ),
  'dash.balance': (en: 'Club balance', id: 'Saldo klub', fr: 'Solde du club'),
  'dash.last5': (
    en: 'Last 5 matches',
    id: '5 laga terakhir',
    fr: '5 derniers matchs',
  ),
  'dash.yesterday': (
    en: 'Yesterday at the club ({date})',
    id: 'Kemarin di klub ({date})',
    fr: 'Hier au club ({date})',
  ),
  'dash.quietDay': (
    en: 'A quiet day, nothing important happened.',
    id: 'Hari yang tenang, tidak ada kejadian penting.',
    fr: 'Journée calme, rien d\'important.',
  ),
  'dash.nextMatch': (
    en: 'Next match',
    id: 'Laga berikutnya',
    fr: 'Prochain match',
  ),
  'dash.matchToday': (
    en: 'Match day today',
    id: 'Hari ini ada laga',
    fr: 'Jour de match',
  ),
  'dash.seasonOver': (
    en: 'The season is over.',
    id: 'Musim sudah selesai.',
    fr: 'La saison est terminée.',
  ),
  'dash.noFixtures': (
    en: 'No fixtures scheduled yet.',
    id: 'Belum ada laga terjadwal.',
    fr: 'Aucun match programmé.',
  ),
  'dash.today': (en: 'Today', id: 'Hari ini', fr: 'Aujourd\'hui'),
  'dash.tomorrow': (en: 'Tomorrow', id: 'Besok', fr: 'Demain'),
  'dash.inDays': (en: 'In {n} days', id: '{n} hari lagi', fr: 'Dans {n} jours'),
  'dash.home': (en: 'home', id: 'kandang', fr: 'domicile'),
  'dash.away': (en: 'away', id: 'tandang', fr: 'extérieur'),
  'common.round': (en: 'Matchday {n}', id: 'Pekan {n}', fr: 'Journée {n}'),
  'dash.latestNews': (
    en: 'Latest news',
    id: 'Kabar terbaru',
    fr: 'Dernières nouvelles',
  ),
  'dash.openInbox': (
    en: 'Open inbox',
    id: 'Buka inbox',
    fr: 'Ouvrir les messages',
  ),
  'dash.awaitingDecision': (
    en: 'Awaiting your decision',
    id: 'Menunggu keputusan Anda',
    fr: 'En attente de votre décision',
  ),
  'dash.decisions': (
    en:
        '{n, plural, one{Make # decision in the inbox} other{Make # decisions in the inbox}}',
    id: 'Ambil {n} keputusan di inbox',
    fr: '{n, plural, one{# décision à prendre} other{# décisions à prendre}}',
  ),
  'dash.playMatch': (
    en: 'Play match',
    id: 'Mainkan laga',
    fr: 'Jouer le match',
  ),
  'dash.seasonFinished': (
    en: 'Season over',
    id: 'Musim selesai',
    fr: 'Saison terminée',
  ),
  'dash.continue': (
    en: 'Continue to the next day',
    id: 'Lanjutkan ke hari berikutnya',
    fr: 'Passer au jour suivant',
  ),
  'dash.stopDecision': (
    en: 'There is a decision you need to make.',
    id: 'Ada keputusan yang perlu Anda ambil.',
    fr: 'Une décision vous attend.',
  ),
  'dash.stopMatch': (
    en: 'Your team plays today.',
    id: 'Hari ini tim Anda bertanding.',
    fr: 'Votre équipe joue aujourd\'hui.',
  ),
  'dash.result': (en: 'Match result', id: 'Hasil laga', fr: 'Résultat'),
  'dash.otherMatches': (
    en: 'Other matches today',
    id: 'Laga lain hari ini',
    fr: 'Autres matchs du jour',
  ),
  'dash.noOtherMatches': (
    en: 'No other matches.',
    id: 'Tidak ada laga lain.',
    fr: 'Aucun autre match.',
  ),
  'dash.backHome': (
    en: 'Back to Home',
    id: 'Kembali ke Beranda',
    fr: 'Retour à l\'accueil',
  ),
  'common.error': (
    en: 'Error: {error}',
    id: 'Error: {error}',
    fr: 'Erreur : {error}',
  ),
  'common.noClub': (
    en: 'No club yet.',
    id: 'Belum ada klub.',
    fr: 'Pas encore de club.',
  ),

  // --- Skuad ---
  'squad.tabList': (en: 'Squad List', id: 'Daftar Skuad', fr: 'Effectif'),
  'squad.tabTactics': (en: 'Tactics', id: 'Taktik', fr: 'Tactique'),
  'squad.loadFailed': (
    en: 'Could not load the squad: {error}',
    id: 'Skuad gagal dimuat: {error}',
    fr: 'Impossible de charger l\'effectif : {error}',
  ),
  'squad.playerCount': (
    en: '{n, plural, one{# player} other{# players}}',
    id: '{n} pemain',
    fr: '{n, plural, one{# joueur} other{# joueurs}}',
  ),
  'squad.changeSort': (
    en: 'Change sort',
    id: 'Ubah urutan',
    fr: 'Changer le tri',
  ),
  'squad.sortBy': (
    en: 'Sort by {field}',
    id: 'Urut {field}',
    fr: 'Trier par {field}',
  ),
  'squad.sort.ca': (en: 'ability', id: 'kemampuan', fr: 'niveau'),
  'squad.sort.condition': (en: 'condition', id: 'kondisi', fr: 'condition'),
  'squad.sort.age': (en: 'age', id: 'usia', fr: 'âge'),
  'squad.sort.value': (en: 'market value', id: 'nilai pasar', fr: 'valeur'),
  'squad.sort.name': (en: 'name', id: 'nama', fr: 'nom'),
  'squad.sort.position': (en: 'position', id: 'posisi', fr: 'poste'),
  'squad.onTransferList': (
    en: 'On the transfer list',
    id: 'Masuk daftar jual',
    fr: 'Sur la liste des transferts',
  ),

  // --- Profil pemain ---
  'player.title': (
    en: 'Player profile',
    id: 'Profil pemain',
    fr: 'Profil du joueur',
  ),
  'player.loadFailed': (
    en: 'Could not load the player: {error}',
    id: 'Pemain gagal dimuat: {error}',
    fr: 'Impossible de charger le joueur : {error}',
  ),
  'player.ageNation': (
    en: '{age} years old, {nation}',
    id: '{age} tahun, {nation}',
    fr: '{age} ans, {nation}',
  ),
  'player.forSale': (en: 'For sale', id: 'Dijual', fr: 'À vendre'),
  'player.ca': (en: 'Ability (CA)', id: 'Kemampuan (CA)', fr: 'Niveau (CA)'),
  'player.pa': (en: 'Potential (PA)', id: 'Potensi (PA)', fr: 'Potentiel (PA)'),
  'player.condition': (en: 'Condition', id: 'Kondisi', fr: 'Condition'),
  'player.morale': (en: 'Morale', id: 'Moral', fr: 'Moral'),
  'player.marketValue': (
    en: 'Market value',
    id: 'Nilai pasar',
    fr: 'Valeur marchande',
  ),
  'player.asking': (en: 'Asking price', id: 'Harga minta', fr: 'Prix demandé'),
  'player.askingRival': (
    en: 'Asking price, rival premium',
    id: 'Harga minta, premi rival',
    fr: 'Prix demandé, prime rival',
  ),
  'player.expectedWage': (
    en: 'Expected wage per year',
    id: 'Gaji diharapkan per tahun',
    fr: 'Salaire annuel attendu',
  ),
  'player.agentPrefix': (en: 'Agent ', id: 'Agen ', fr: 'Agent '),
  'player.agentStyle': (
    en: ', {style} style',
    id: ', gaya {style}',
    fr: ', style {style}',
  ),
  'player.noInterest': (
    en: 'No clubs are interested yet.',
    id: 'Belum ada klub yang berminat.',
    fr: 'Aucun club intéressé pour l\'instant.',
  ),
  'player.interestedClubs': (
    en: 'Interested clubs',
    id: 'Klub yang berminat',
    fr: 'Clubs intéressés',
  ),
  'player.interestScore': (
    en: '{level}, score {score}',
    id: '{level}, skor {score}',
    fr: '{level}, score {score}',
  ),
  'player.shortlisted': (
    en: 'Shortlisted',
    id: 'Di shortlist',
    fr: 'Dans la liste',
  ),
  'player.shortlist': (en: 'Shortlist', id: 'Shortlist', fr: 'Liste de suivi'),
  'player.unlist': (
    en: 'Remove from transfer list',
    id: 'Batalkan daftar jual',
    fr: 'Retirer de la liste',
  ),
  'player.list': (
    en: 'Add to transfer list',
    id: 'Masukkan daftar jual',
    fr: 'Mettre sur la liste',
  ),
  'player.makeOffer': (
    en: 'Make an offer',
    id: 'Ajukan tawaran',
    fr: 'Faire une offre',
  ),
  'player.windowOpen': (
    en: 'Transfer window open until {date}.',
    id: 'Bursa buka sampai {date}.',
    fr: 'Mercato ouvert jusqu\'au {date}.',
  ),
  'player.windowClosed': (
    en: 'Transfer window closed, reopens {date}.',
    id: 'Bursa tutup, buka lagi {date}.',
    fr: 'Mercato fermé, réouverture le {date}.',
  ),
  'player.offerFrom': (
    en: 'Offer from {club}',
    id: 'Tawaran {club}',
    fr: 'Offre de {club}',
  ),
  'player.feeAgreedWith': (
    en: 'Fee agreed with {club}',
    id: 'Harga disepakati dengan {club}',
    fr: 'Montant convenu avec {club}',
  ),
  'player.negotiatingWith': (
    en: 'Negotiating with {club}',
    id: 'Negosiasi dengan {club}',
    fr: 'Négociation avec {club}',
  ),
  'player.bargaining': (
    en: 'Bargaining in progress, agent patience {n}%',
    id: 'Tawar-menawar berjalan, kesabaran agen {n}%',
    fr: 'Négociation en cours, patience de l\'agent {n} %',
  ),
  'player.wagePerYear': (
    en: 'Wage per year',
    id: 'Gaji per tahun',
    fr: 'Salaire annuel',
  ),
  'player.expires': (en: 'Expires', id: 'Berakhir', fr: 'Fin'),
  'player.role': (en: 'Role', id: 'Peran', fr: 'Rôle'),

  // --- Taktik ---
  'tactics.title': (
    en: 'Tactics & Lineup',
    id: 'Taktik & Lineup',
    fr: 'Tactique et composition',
  ),
  'tactics.startingXI': (
    en: 'Starting XI',
    id: 'Sebelas pertama',
    fr: 'Onze de départ',
  ),
  'tactics.bench': (
    en: 'Substitutes ({n} of {max})',
    id: 'Cadangan ({n} dari {max})',
    fr: 'Remplaçants ({n} sur {max})',
  ),
  'tactics.pickStarterFirst': (
    en: 'Pick a starter first, then tap a substitute to swap.',
    id: 'Pilih starter dulu, lalu ketuk cadangan untuk menukar.',
    fr: 'Choisissez d\'abord un titulaire, puis touchez un remplaçant.',
  ),
  'tactics.formation': (en: 'Formation', id: 'Formasi', fr: 'Formation'),
  'tactics.auto': (
    en: 'Auto pick',
    id: 'Susun otomatis',
    fr: 'Composition auto',
  ),
  'tactics.mentality': (en: 'Mentality', id: 'Mentalitas', fr: 'Mentalité'),
  'tactics.swapHint': (
    en:
        'Tap a player in the starting XI, then tap another player to swap their positions.',
    id:
        'Ketuk pemain di sebelas pertama, lalu ketuk pemain lain untuk menukar posisinya.',
    fr: 'Touchez un titulaire, puis un autre joueur pour les échanger.',
  ),
  'tactics.swapping': (
    en: 'Swapping {name}. Tap the replacement.',
    id: 'Menukar {name}. Ketuk pemain penggantinya.',
    fr: 'Échange de {name}. Touchez le remplaçant.',
  ),
  'search.title': (
    en: 'Player Search',
    id: 'Cari Pemain',
    fr: 'Recherche de joueurs',
  ),
};
