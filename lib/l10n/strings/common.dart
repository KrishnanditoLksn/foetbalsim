import 'tr_entry.dart';

/// Label enum dan teks umum yang dipakai di banyak layar.
const Map<String, Tr> commonStrings = {
  // --- Umum ---
  'common.cancel': (en: 'Cancel', id: 'Batal', fr: 'Annuler'),
  'common.close': (en: 'Close', id: 'Tutup', fr: 'Fermer'),
  'common.delete': (en: 'Delete', id: 'Hapus', fr: 'Supprimer'),
  'common.save': (en: 'Save', id: 'Simpan', fr: 'Enregistrer'),
  'common.ok': (en: 'OK', id: 'OK', fr: 'OK'),
  'common.yes': (en: 'Yes', id: 'Ya', fr: 'Oui'),
  'common.no': (en: 'No', id: 'Tidak', fr: 'Non'),
  'common.back': (en: 'Back', id: 'Kembali', fr: 'Retour'),
  'common.retry': (en: 'Try again', id: 'Coba lagi', fr: 'Réessayer'),
  'common.language': (en: 'Language', id: 'Bahasa', fr: 'Langue'),
  'common.manager': (
    en: 'Manager {name}',
    id: 'Manajer {name}',
    fr: 'Entraîneur {name}',
  ),
  'common.years': (
    en: '{n, plural, one{# year} other{# years}}',
    id: '{n} tahun',
    fr: '{n, plural, one{# an} other{# ans}}',
  ),
  'common.yearsShort': (en: '{n} yrs', id: '{n} thn', fr: '{n} ans'),
  'common.days': (
    en: '{n, plural, one{# day} other{# days}}',
    id: '{n} hari',
    fr: '{n, plural, one{# jour} other{# jours}}',
  ),
  'common.age': (en: '{n} y/o', id: '{n} th', fr: '{n} ans'),
  'common.perYear': (
    en: '{amount}/yr',
    id: '{amount}/tahun',
    fr: '{amount}/an',
  ),
  'common.dash': (en: '–', id: '–', fr: '–'),

  // --- Grup atribut ---
  'attrGroup.technical': (en: 'Technical', id: 'Teknik', fr: 'Technique'),
  'attrGroup.mental': (en: 'Mental', id: 'Mental', fr: 'Mental'),
  'attrGroup.physical': (en: 'Physical', id: 'Fisik', fr: 'Physique'),
  'attrGroup.goalkeeping': (en: 'Goalkeeping', id: 'Kiper', fr: 'Gardien'),

  // --- Atribut ---
  'attr.finishing': (en: 'Finishing', id: 'Penyelesaian', fr: 'Finition'),
  'attr.passing': (en: 'Passing', id: 'Operan', fr: 'Passes'),
  'attr.dribbling': (en: 'Dribbling', id: 'Dribel', fr: 'Dribble'),
  'attr.firstTouch': (
    en: 'First Touch',
    id: 'Sentuhan Pertama',
    fr: 'Contrôle',
  ),
  'attr.crossing': (en: 'Crossing', id: 'Umpan Silang', fr: 'Centres'),
  'attr.tackling': (en: 'Tackling', id: 'Tekel', fr: 'Tacle'),
  'attr.heading': (en: 'Heading', id: 'Sundulan', fr: 'Jeu de tête'),
  'attr.technique': (en: 'Technique', id: 'Teknik', fr: 'Technique'),
  'attr.decisions': (en: 'Decisions', id: 'Keputusan', fr: 'Décisions'),
  'attr.positioning': (en: 'Positioning', id: 'Posisi', fr: 'Placement'),
  'attr.vision': (en: 'Vision', id: 'Visi', fr: 'Vision du jeu'),
  'attr.composure': (en: 'Composure', id: 'Ketenangan', fr: 'Sang-froid'),
  'attr.workRate': (en: 'Work Rate', id: 'Etos Kerja', fr: 'Volume de jeu'),
  'attr.aggression': (en: 'Aggression', id: 'Agresi', fr: 'Agressivité'),
  'attr.pace': (en: 'Pace', id: 'Kecepatan', fr: 'Vitesse'),
  'attr.acceleration': (
    en: 'Acceleration',
    id: 'Akselerasi',
    fr: 'Accélération',
  ),
  'attr.stamina': (en: 'Stamina', id: 'Stamina', fr: 'Endurance'),
  'attr.strength': (en: 'Strength', id: 'Kekuatan', fr: 'Puissance'),
  'attr.agility': (en: 'Agility', id: 'Kelincahan', fr: 'Agilité'),
  'attr.handling': (
    en: 'Handling',
    id: 'Penanganan Bola',
    fr: 'Prise de balle',
  ),
  'attr.reflexes': (en: 'Reflexes', id: 'Refleks', fr: 'Réflexes'),
  'attr.oneOnOnes': (
    en: 'One on Ones',
    id: 'Satu Lawan Satu',
    fr: 'Face-à-face',
  ),
  'attr.aerialReach': (
    en: 'Aerial Reach',
    id: 'Jangkauan Udara',
    fr: 'Jeu aérien',
  ),

  // --- Kategori inbox ---
  'inboxCat.board': (en: 'Board', id: 'Dewan', fr: 'Direction'),
  'inboxCat.match': (en: 'Match', id: 'Pertandingan', fr: 'Match'),
  'inboxCat.scouting': (en: 'Scouting', id: 'Scouting', fr: 'Recrutement'),
  'inboxCat.finance': (en: 'Finance', id: 'Keuangan', fr: 'Finances'),
  'inboxCat.contract': (en: 'Contract', id: 'Kontrak', fr: 'Contrat'),
  'inboxCat.season': (en: 'Season', id: 'Musim', fr: 'Saison'),
  'inboxCat.transfer': (en: 'Transfer', id: 'Transfer', fr: 'Transfert'),

  // --- Grup posisi ---
  'posGroup.goalkeeper': (en: 'Goalkeeper', id: 'Kiper', fr: 'Gardien'),
  'posGroup.defender': (en: 'Defender', id: 'Bek', fr: 'Défenseur'),
  'posGroup.midfielder': (en: 'Midfielder', id: 'Gelandang', fr: 'Milieu'),
  'posGroup.forward': (en: 'Forward', id: 'Penyerang', fr: 'Attaquant'),

  // --- Status skuad ---
  'squadStatus.keyPlayer': (en: 'Key player', id: 'Pilar', fr: 'Cadre'),
  'squadStatus.starter': (en: 'Starter', id: 'Starter', fr: 'Titulaire'),
  'squadStatus.rotation': (en: 'Rotation', id: 'Rotasi', fr: 'Rotation'),
  'squadStatus.backup': (en: 'Backup', id: 'Cadangan', fr: 'Remplaçant'),
  'squadStatus.youth': (en: 'Youth', id: 'Muda', fr: 'Jeune'),

  // --- Mentalitas ---
  'mentality.defensive': (en: 'Defensive', id: 'Bertahan', fr: 'Défensive'),
  'mentality.balanced': (en: 'Balanced', id: 'Seimbang', fr: 'Équilibrée'),
  'mentality.attacking': (en: 'Attacking', id: 'Menyerang', fr: 'Offensive'),

  // --- Status tawaran transfer ---
  'offerStatus.pending': (en: 'Pending', id: 'Menunggu', fr: 'En attente'),
  'offerStatus.awaitingContract': (
    en: 'Contract talks',
    id: 'Negosiasi kontrak',
    fr: 'Négociation du contrat',
  ),
  'offerStatus.countered': (
    en: 'Counter-offer',
    id: 'Kontra-tawaran',
    fr: 'Contre-offre',
  ),
  'offerStatus.completed': (en: 'Completed', id: 'Selesai', fr: 'Conclu'),
  'offerStatus.rejected': (en: 'Rejected', id: 'Ditolak', fr: 'Refusé'),
  'offerStatus.failed': (en: 'Failed', id: 'Gagal', fr: 'Échoué'),
  'offerStatus.withdrawn': (en: 'Withdrawn', id: 'Dibatalkan', fr: 'Retiré'),

  // --- Jenis transfer ---
  'transferType.buy': (en: 'Purchase', id: 'Pembelian', fr: 'Achat'),
  'transferType.sell': (en: 'Sale', id: 'Penjualan', fr: 'Vente'),
  'transferType.aiDeal': (
    en: 'AI transfer',
    id: 'Transfer AI',
    fr: 'Transfert IA',
  ),

  // --- Gaya agen ---
  'agentStyle.compromising': (
    en: 'Accommodating',
    id: 'Kompromistis',
    fr: 'Conciliant',
  ),
  'agentStyle.professional': (
    en: 'Professional',
    id: 'Profesional',
    fr: 'Professionnel',
  ),
  'agentStyle.stubborn': (en: 'Stubborn', id: 'Keras kepala', fr: 'Têtu'),

  // --- Kepribadian klub AI ---
  'clubPersonality.bigSpender': (
    en: 'Big Spender',
    id: 'Big Spender',
    fr: 'Gros dépensier',
  ),
  'clubPersonality.sellingClub': (
    en: 'Selling Club',
    id: 'Selling Club',
    fr: 'Club vendeur',
  ),
  'clubPersonality.moneyball': (
    en: 'Moneyball',
    id: 'Moneyball',
    fr: 'Moneyball',
  ),
  'clubPersonality.youthDeveloper': (
    en: 'Youth Developer',
    id: 'Youth Developer',
    fr: 'Formateur',
  ),
  'clubPersonality.survivalMode': (
    en: 'Survival Mode',
    id: 'Survival Mode',
    fr: 'Mode survie',
  ),

  // --- Pencarian pemain ---
  'searchStatus.all': (en: 'All', id: 'Semua', fr: 'Tous'),
  'searchStatus.forSale': (
    en: 'Transfer List',
    id: 'Daftar Jual',
    fr: 'À vendre',
  ),
  'searchStatus.expiringSoon': (
    en: 'Contract ends ≤ 6 mo',
    id: 'Kontrak Habis ≤ 6 Bln',
    fr: 'Fin de contrat ≤ 6 mois',
  ),
  'searchStatus.freeAgent': (en: 'Free Agent', id: 'Agen Bebas', fr: 'Libre'),
  'playerSort.ca': (en: 'CA', id: 'CA', fr: 'CA'),
  'playerSort.pa': (en: 'PA', id: 'PA', fr: 'PA'),
  'playerSort.age': (en: 'Age', id: 'Usia', fr: 'Âge'),
  'playerSort.marketValue': (
    en: 'Market Value',
    id: 'Nilai Pasar',
    fr: 'Valeur marchande',
  ),
  'playerSort.wage': (en: 'Wage', id: 'Gaji', fr: 'Salaire'),
  'playerSort.name': (en: 'Name', id: 'Nama', fr: 'Nom'),
};
