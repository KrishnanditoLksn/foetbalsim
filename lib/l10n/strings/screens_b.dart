import 'tr_entry.dart';

/// Jadwal & klasemen, inbox, layar pertandingan.
const Map<String, Tr> screensBStrings = {
  // --- Jadwal & klasemen ---
  'fixtures.title': (
    en: 'Fixtures & Table',
    id: 'Jadwal & Klasemen',
    fr: 'Calendrier et classement',
  ),
  'fixtures.tabClub': (en: 'Club', id: 'Klub', fr: 'Club'),
  'fixtures.tabTable': (en: 'Table', id: 'Klasemen', fr: 'Classement'),
  'fixtures.tabRound': (en: 'Matchday', id: 'Pekan', fr: 'Journée'),
  'fixtures.loadFailed': (
    en: 'Could not load: {error}',
    id: 'Gagal memuat: {error}',
    fr: 'Chargement impossible : {error}',
  ),
  'fixtures.atHome': (en: 'Home', id: 'Di kandang', fr: 'Domicile'),
  'fixtures.away': (en: 'Away', id: 'Tandang', fr: 'Extérieur'),
  'fixtures.club': (en: 'Club', id: 'Klub', fr: 'Club'),
  'fixtures.played': (en: 'Played', id: 'Main', fr: 'Joués'),
  'fixtures.playedShort': (en: 'P', id: 'Main', fr: 'J'),
  'fixtures.won': (en: 'Won', id: 'Menang', fr: 'Gagnés'),
  'fixtures.wonShort': (en: 'W', id: 'M', fr: 'G'),
  'fixtures.drawn': (en: 'Drawn', id: 'Seri', fr: 'Nuls'),
  'fixtures.drawnShort': (en: 'D', id: 'S', fr: 'N'),
  'fixtures.lost': (en: 'Lost', id: 'Kalah', fr: 'Perdus'),
  'fixtures.lostShort': (en: 'L', id: 'K', fr: 'P'),
  'fixtures.goalDiff': (
    en: 'Goal difference',
    id: 'Selisih gol',
    fr: 'Différence de buts',
  ),
  'fixtures.goalDiffShort': (en: 'GD', id: 'SG', fr: 'Diff'),
  'fixtures.points': (en: 'Points', id: 'Poin', fr: 'Points'),
  'fixtures.pointsShort': (en: 'Pts', id: 'Poin', fr: 'Pts'),
  'fixtures.ucl': (
    en: 'Champions League',
    id: 'Liga Champions',
    fr: 'Ligue des champions',
  ),
  'fixtures.uel': (en: 'Europa League', id: 'Liga Eropa', fr: 'Ligue Europa'),
  'fixtures.relegation': (en: 'Relegation', id: 'Degradasi', fr: 'Relégation'),
  'fixtures.promotion': (en: 'Promotion', id: 'Promosi', fr: 'Promotion'),
  'fixtures.playoff': (en: 'Play-off', id: 'Playoff', fr: 'Barrages'),
  'fixtures.legend': (
    en: 'W/D/L = Won/Drawn/Lost · GD = goal difference',
    id: 'M/S/K = Menang/Seri/Kalah · SG = selisih gol',
    fr: 'G/N/P = Gagnés/Nuls/Perdus · Diff = différence de buts',
  ),
  'fixtures.roundOf': (
    en: 'Matchday {n} of {max}',
    id: 'Pekan {n} dari {max}',
    fr: 'Journée {n} sur {max}',
  ),

  // --- Inbox ---
  'inbox.loadFailed': (
    en: 'Could not load the inbox: {error}',
    id: 'Gagal memuat inbox: {error}',
    fr: 'Impossible de charger les messages : {error}',
  ),
  'inbox.empty': (
    en: 'Inbox is empty.',
    id: 'Inbox kosong.',
    fr: 'Aucun message.',
  ),
  'inbox.filterAction': (
    en: 'Awaiting decision ({n})',
    id: 'Menunggu keputusan ({n})',
    fr: 'Décision requise ({n})',
  ),
  'inbox.filterUnread': (
    en: 'Unread ({n})',
    id: 'Belum dibaca ({n})',
    fr: 'Non lus ({n})',
  ),
  'inbox.noneAction': (
    en: 'No decisions waiting.',
    id: 'Tidak ada keputusan yang menunggu.',
    fr: 'Aucune décision en attente.',
  ),
  'inbox.allRead': (
    en: 'All messages have been read.',
    id: 'Semua pesan sudah dibaca.',
    fr: 'Tous les messages ont été lus.',
  ),
  'inbox.viewPlayer': (
    en: 'View player',
    id: 'Lihat pemain',
    fr: 'Voir le joueur',
  ),
  'inbox.acceptTarget': (
    en: 'Accept target',
    id: 'Terima target',
    fr: 'Accepter l\'objectif',
  ),
  'inbox.letGo': (
    en: 'Let him go',
    id: 'Biarkan pergi',
    fr: 'Le laisser partir',
  ),
  'inbox.renew': (en: 'Renew', id: 'Perpanjang', fr: 'Prolonger'),
  'inbox.reject': (en: 'Reject', id: 'Tolak', fr: 'Refuser'),
  'inbox.accept': (en: 'Accept', id: 'Terima', fr: 'Accepter'),
  'inbox.enterRoom': (
    en: 'Enter negotiation room',
    id: 'Masuk ruang negosiasi',
    fr: 'Salle de négociation',
  ),
  'inbox.cancelNegotiation': (en: 'Call off', id: 'Batalkan', fr: 'Annuler'),

  // --- Layar pertandingan ---
  'match.title': (en: 'Match', id: 'Laga', fr: 'Match'),
  'match.notReady': (
    en: 'Match not ready.',
    id: 'Laga belum siap.',
    fr: 'Match pas prêt.',
  ),
  'match.saveFailed': (
    en: 'Could not save: {error}',
    id: 'Gagal menyimpan: {error}',
    fr: 'Échec de l\'enregistrement : {error}',
  ),
  'match.leaveTitle': (
    en: 'Leave the match?',
    id: 'Keluar dari laga?',
    fr: 'Quitter le match ?',
  ),
  'match.leaveBody': (
    en:
        'The match isn\'t finished or saved. If you leave now, it will restart from minute 0 when reopened.',
    id:
        'Laga belum selesai dan belum disimpan. Jika keluar sekarang, laga akan dimulai ulang dari menit 0 saat dibuka lagi.',
    fr:
        'Le match n\'est ni terminé ni enregistré. Si vous quittez, il reprendra à la minute 0.',
  ),
  'match.keepPlaying': (en: 'Keep playing', id: 'Lanjutkan', fr: 'Continuer'),
  'match.leave': (en: 'Leave', id: 'Keluar', fr: 'Quitter'),
  'match.loadFailed': (
    en: 'Could not load the match: {error}',
    id: 'Gagal memuat laga: {error}',
    fr: 'Impossible de charger le match : {error}',
  ),
  'match.notStarted': (
    en: 'Not started',
    id: 'Belum mulai',
    fr: 'Pas commencé',
  ),
  'match.halfTimeBanner': (
    en: 'HALF-TIME · Free substitutions',
    id: 'JEDA BABAK PERTAMA · Pergantian bebas',
    fr: 'MI-TEMPS · Changements libres',
  ),
  'match.pause': (en: 'Pause', id: 'Jeda', fr: 'Pause'),
  'match.play': (en: 'Play', id: 'Mainkan', fr: 'Lecture'),
  'match.skip': (
    en: 'Skip to the end',
    id: 'Skip ke akhir',
    fr: 'Aller à la fin',
  ),
  'match.subsButton': (
    en: 'Subs {subs}/{maxSubs} · Windows {windows}/{maxWindows}',
    id: 'Ganti · Subs {subs}/{maxSubs} · Jendela {windows}/{maxWindows}',
    fr: 'Changements {subs}/{maxSubs} · Fenêtres {windows}/{maxWindows}',
  ),
  'match.possession': (en: 'Possession', id: 'Penguasaan', fr: 'Possession'),
  'match.shots': (en: 'Shots', id: 'Tembakan', fr: 'Tirs'),
  'match.onTarget': (en: 'On target', id: 'Tepat sasaran', fr: 'Cadrés'),
  'match.saves': (en: 'Saves', id: 'Penyelamatan', fr: 'Arrêts'),
  'match.fouls': (en: 'Fouls', id: 'Pelanggaran', fr: 'Fautes'),
  'match.cards': (en: 'Cards', id: 'Kartu', fr: 'Cartons'),
  'match.saving': (
    en: 'Saving...',
    id: 'Menyimpan...',
    fr: 'Enregistrement...',
  ),
  'match.saveAndReturn': (
    en: 'Save & Return',
    id: 'Simpan & Kembali',
    fr: 'Enregistrer et revenir',
  ),
  'match.subsLeft': (
    en: 'Substitution ({n} left)',
    id: 'Pergantian (sisa {n})',
    fr: 'Changement ({n} restants)',
  ),
  'match.subOut': (
    en: 'Off (on the pitch)',
    id: 'Keluar (di lapangan)',
    fr: 'Sortant (sur le terrain)',
  ),
  'match.subIn': (en: 'On (bench)', id: 'Masuk (bangku)', fr: 'Entrant (banc)'),
  'match.substitute': (
    en: 'Make substitution',
    id: 'Ganti pemain',
    fr: 'Effectuer le changement',
  ),
};
