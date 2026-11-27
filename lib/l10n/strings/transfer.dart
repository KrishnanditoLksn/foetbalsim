import 'tr_entry.dart';

/// Pasar transfer, dialog tawaran, pencarian pemain, Ruang Negosiasi.
const Map<String, Tr> transferStrings = {
  // --- Alur & tombol tawaran ---
  'flow.bidSent': (
    en: 'Offer sent. The club will respond within 1–2 days.',
    id: 'Tawaran dikirim. Respons klub dalam 1–2 hari.',
    fr: 'Offre envoyée. Réponse du club sous 1 à 2 jours.',
  ),
  'flow.negotiate': (en: 'Negotiate', id: 'Negosiasi', fr: 'Négocier'),
  'flow.continueNegotiation': (
    en: 'Continue negotiation',
    id: 'Lanjutkan negosiasi',
    fr: 'Reprendre la négociation',
  ),
  'flow.offerRejected': (
    en: 'Offer rejected.',
    id: 'Tawaran ditolak.',
    fr: 'Offre refusée.',
  ),
  'flow.negotiationCancelled': (
    en: 'Negotiation called off.',
    id: 'Negosiasi dibatalkan.',
    fr: 'Négociation annulée.',
  ),
  'flow.awaitingSellerOn': (
    en: 'Waiting for the selling club to respond ({date}).',
    id: 'Menunggu respons klub penjual ({date}).',
    fr: 'En attente de la réponse du club vendeur ({date}).',
  ),
  'flow.incomingOffer': (
    en: 'Incoming offer',
    id: 'Tawaran masuk',
    fr: 'Offre reçue',
  ),

  // --- Dialog tawaran ---
  'bid.tooLow': (
    en: 'Too low: very likely to be rejected.',
    id: 'Terlalu rendah: kemungkinan besar ditolak.',
    fr: 'Trop bas : probablement refusé.',
  ),
  'bid.belowAsking': (
    en: 'Below asking price: likely to get a counter-offer.',
    id: 'Di bawah harga minta: kemungkinan dibalas kontra-tawaran.',
    fr: 'Sous le prix demandé : contre-offre probable.',
  ),
  'bid.atAsking': (
    en: 'At asking price: likely to be accepted.',
    id: 'Sesuai harga minta: kemungkinan diterima.',
    fr: 'Au prix demandé : probablement accepté.',
  ),
  'bid.asking': (
    en: 'Club\'s asking price: {fee}',
    id: 'Harga minta klub: {fee}',
    fr: 'Prix demandé par le club : {fee}',
  ),
  'bid.rivalPremium': (
    en: 'Includes a +30% local rival premium.',
    id: 'Termasuk premi rival lokal +30%.',
    fr: 'Inclut une prime de rivalité locale de +30 %.',
  ),
  'bid.feeLabel': (
    en: 'Transfer fee ({unit})',
    id: 'Biaya transfer ({unit})',
    fr: 'Indemnité de transfert ({unit})',
  ),
  'bid.feeHelper': (
    en: '1,000 = €1 million',
    id: '1.000 = €1 juta',
    fr: '1 000 = 1 M€',
  ),
  'bid.payment': (en: 'Payment', id: 'Pembayaran', fr: 'Paiement'),
  'bid.upfront': (en: 'Upfront', id: 'Langsung', fr: 'Comptant'),
  'bid.sellOnLabel': (
    en: 'Sell-on clause for the seller',
    id: 'Sell-on clause untuk penjual',
    fr: 'Clause de revente pour le vendeur',
  ),
  'bid.sellOnNone': (en: 'None', id: 'Tanpa', fr: 'Aucune'),
  'bid.sellOnPct': (
    en: '{pct}% of next sale',
    id: '{pct}% penjualan berikutnya',
    fr: '{pct} % de la prochaine vente',
  ),
  'bid.valueToSeller': (
    en: 'Value to seller: {value} ({pct}% of asking price)',
    id: 'Nilai bagi penjual: {value} ({pct}% dari harga minta)',
    fr: 'Valeur pour le vendeur : {value} ({pct} % du prix demandé)',
  ),
  'bid.paidUpfront': (
    en: 'Paid upfront: {amount}.',
    id: 'Dibayar langsung: {amount}.',
    fr: 'Payé comptant : {amount}.',
  ),
  'bid.paidInstallments': (
    en: '{amount} upfront, the rest in instalments every 1 July.',
    id: 'Di muka {amount}, sisanya dicicil tiap 1 Juli.',
    fr: '{amount} d\'avance, le reste en versements chaque 1er juillet.',
  ),
  'bid.budgetLine': (
    en: 'Transfer budget {budget} · balance {balance}',
    id: 'Anggaran transfer {budget} · saldo {balance}',
    fr: 'Budget transferts {budget} · solde {balance}',
  ),
  'bid.overBudget': (
    en: 'Fee exceeds the transfer budget.',
    id: 'Biaya melebihi anggaran transfer.',
    fr: 'Le montant dépasse le budget transferts.',
  ),
  'bid.overBalance': (
    en: 'Not enough balance for the upfront payment.',
    id: 'Saldo tidak cukup untuk pembayaran di muka.',
    fr: 'Solde insuffisant pour le paiement initial.',
  ),
  'bid.note': (
    en:
        'Response within 1–2 days. If it isn\'t a match yet, the player\'s agent will invite you to bargain in the Negotiation Room.',
    id:
        'Respons dalam 1–2 hari. Bila belum cocok, agen pemain mengajak Anda tawar-menawar di Ruang Negosiasi.',
    fr:
        'Réponse sous 1 à 2 jours. Sinon, l\'agent du joueur vous invitera à négocier dans la salle de négociation.',
  ),
  'bid.send': (en: 'Send', id: 'Kirim', fr: 'Envoyer'),

  // --- Pasar transfer ---
  'transfer.title': (
    en: 'Transfer Market',
    id: 'Pasar Transfer',
    fr: 'Mercato',
  ),
  'transfer.tabToday': (
    en: 'Today\'s Market',
    id: 'Bursa Hari Ini',
    fr: 'Aujourd\'hui',
  ),
  'transfer.tabNegotiations': (
    en: 'Negotiations',
    id: 'Negosiasi',
    fr: 'Négociations',
  ),
  'transfer.tabHistory': (en: 'History', id: 'Riwayat', fr: 'Historique'),
  'transfer.searchFullscreen': (
    en: 'Full-screen player search',
    id: 'Cari pemain layar penuh',
    fr: 'Recherche plein écran',
  ),
  'transfer.rules': (
    en:
        'European windows: 1 July – 31 August and 1–31 January.\nMax {moves} in & {moves} out per window.\nSquad {min}–{max} players.\nBargain with the player\'s agent in the Negotiation Room. If the agent walks out, the player can only be approached again a week later.',
    id:
        'Jendela Eropa: 1 Juli – 31 Agustus dan 1–31 Januari.\nMaks {moves} masuk & {moves} keluar per jendela.\nSkuad {min}–{max} pemain.\nTawar-menawar dengan agen pemain di Ruang Negosiasi. Bila agen walk-out, pemain baru bisa ditawar lagi seminggu kemudian.',
    fr:
        'Fenêtres européennes : 1er juillet – 31 août et 1er–31 janvier.\nMax {moves} arrivées et {moves} départs par fenêtre.\nEffectif de {min} à {max} joueurs.\nNégociez avec l\'agent dans la salle de négociation. S\'il claque la porte, le joueur ne pourra être approché qu\'une semaine plus tard.',
  ),
  'transfer.rulesTitle': (
    en: 'Transfer rules',
    id: 'Ketentuan transfer',
    fr: 'Règles des transferts',
  ),
  'transfer.deadlineDay': (
    en: 'Last day of the transfer window',
    id: 'Hari terakhir bursa transfer',
    fr: 'Dernier jour du mercato',
  ),
  'transfer.openDaysLeft': (
    en: 'Window open, {n} days left',
    id: 'Bursa buka, {n} hari lagi',
    fr: 'Mercato ouvert, encore {n} jours',
  ),
  'transfer.closed': (
    en: 'Transfer window closed',
    id: 'Bursa transfer tutup',
    fr: 'Mercato fermé',
  ),
  'transfer.closesOn': (
    en: 'Closes {date}',
    id: 'Tutup {date}',
    fr: 'Fermeture le {date}',
  ),
  'transfer.reopensOn': (
    en: 'Reopens {date}',
    id: 'Buka lagi {date}',
    fr: 'Réouverture le {date}',
  ),
  'transfer.noNews': (
    en:
        'No market news yet. Rumours and transfers appear every day while the window is open.',
    id:
        'Belum ada berita bursa. Rumor dan transfer muncul setiap hari selama jendela transfer buka.',
    fr:
        'Aucune actualité. Rumeurs et transferts apparaissent chaque jour pendant le mercato.',
  ),
  'transfer.shortlistEmpty': (
    en: 'Shortlist is empty. Add players from Player Search.',
    id: 'Shortlist kosong. Tambahkan pemain dari Cari Pemain.',
    fr: 'Liste vide. Ajoutez des joueurs depuis la recherche.',
  ),
  'transfer.removeShortlist': (
    en: 'Remove from shortlist',
    id: 'Hapus dari shortlist',
    fr: 'Retirer de la liste',
  ),
  'transfer.noNegotiations': (
    en:
        'No negotiations yet. Make an offer from a player\'s profile while the window is open.',
    id:
        'Belum ada negosiasi. Ajukan tawaran dari detail pemain saat jendela transfer buka.',
    fr:
        'Aucune négociation. Faites une offre depuis la fiche d\'un joueur pendant le mercato.',
  ),
  'transfer.playerN': (
    en: 'Player #{n}',
    id: 'Pemain #{n}',
    fr: 'Joueur n°{n}',
  ),
  'transfer.offerFrom': (
    en: 'Offer from {club}',
    id: 'Tawaran dari {club}',
    fr: 'Offre de {club}',
  ),
  'transfer.offerTo': (en: 'To {club}', id: 'Ke {club}', fr: 'Vers {club}'),
  'transfer.active': (
    en: 'Ongoing ({n})',
    id: 'Berjalan ({n})',
    fr: 'En cours ({n})',
  ),
  'transfer.noneActive': (
    en: 'No ongoing negotiations.',
    id: 'Tidak ada negosiasi berjalan.',
    fr: 'Aucune négociation en cours.',
  ),
  'transfer.done': (
    en: 'Finished ({n})',
    id: 'Selesai ({n})',
    fr: 'Terminées ({n})',
  ),
  'transfer.bargainContract': (
    en: 'Contract bargaining in progress, agent patience {n}%',
    id: 'Tawar-menawar kontrak berjalan, kesabaran agen {n}%',
    fr: 'Négociation du contrat en cours, patience de l\'agent {n} %',
  ),
  'transfer.bargainFee': (
    en: 'Fee bargaining in progress, agent patience {n}%',
    id: 'Tawar-menawar harga berjalan, kesabaran agen {n}%',
    fr: 'Négociation du montant en cours, patience de l\'agent {n} %',
  ),
  'transfer.noHistory': (
    en: 'No transfers in the league yet. Wait for the window to open.',
    id: 'Belum ada transfer di liga. Tunggu jendela dibuka.',
    fr: 'Aucun transfert dans la ligue. Attendez l\'ouverture du mercato.',
  ),

  // --- Pencarian pemain ---
  'search.hint': (
    en: 'Search player name',
    id: 'Cari nama pemain',
    fr: 'Nom du joueur',
  ),
  'search.position': (en: 'Position', id: 'Posisi', fr: 'Poste'),
  'search.allPositions': (
    en: 'All positions',
    id: 'Semua posisi',
    fr: 'Tous les postes',
  ),
  'search.sortBy': (
    en: 'Sort: {field}',
    id: 'Urut: {field}',
    fr: 'Tri : {field}',
  ),
  'search.ascending': (en: 'Ascending', id: 'Naik', fr: 'Croissant'),
  'search.descending': (en: 'Descending', id: 'Turun', fr: 'Décroissant'),
  'search.advanced': (
    en: 'Advanced filters',
    id: 'Filter lanjutan',
    fr: 'Filtres avancés',
  ),
  'search.ageMin': (en: 'Min age', id: 'Usia min', fr: 'Âge min'),
  'search.ageMax': (en: 'Max age', id: 'Usia maks', fr: 'Âge max'),
  'search.caMin': (en: 'Min CA', id: 'CA min', fr: 'CA min'),
  'search.caMax': (en: 'Max CA', id: 'CA maks', fr: 'CA max'),
  'search.maxValue': (
    en: 'Max value (€M)',
    id: 'Nilai maks (€ jt)',
    fr: 'Valeur max (M€)',
  ),
  'search.league': (en: 'League', id: 'Liga', fr: 'Ligue'),
  'search.allLeagues': (
    en: 'All leagues',
    id: 'Semua liga',
    fr: 'Toutes les ligues',
  ),
  'search.noResults': (
    en: 'No players match the filters.',
    id: 'Tidak ada pemain yang cocok dengan filter.',
    fr: 'Aucun joueur ne correspond aux filtres.',
  ),

  // --- Ruang Negosiasi ---
  'room.title': (
    en: 'Negotiation room',
    id: 'Ruang negosiasi',
    fr: 'Salle de négociation',
  ),
  'room.amountPositive': (
    en: 'Enter an amount greater than zero.',
    id: 'Isi nominal lebih dari nol.',
    fr: 'Saisissez un montant supérieur à zéro.',
  ),
  'room.overBudget': (
    en: 'Exceeds the transfer budget ({budget}).',
    id: 'Melebihi anggaran transfer ({budget}).',
    fr: 'Dépasse le budget transferts ({budget}).',
  ),
  'room.overBalance': (
    en: 'Upfront payment {upfront} exceeds the balance ({balance}).',
    id: 'Pembayaran di muka {upfront} melebihi saldo ({balance}).',
    fr: 'Le paiement initial de {upfront} dépasse le solde ({balance}).',
  ),
  'room.rejectTitle': (
    en: 'Reject the offer?',
    id: 'Tolak tawaran?',
    fr: 'Refuser l\'offre ?',
  ),
  'room.cancelTitle': (
    en: 'Call off the negotiation?',
    id: 'Batalkan negosiasi?',
    fr: 'Annuler la négociation ?',
  ),
  'room.rejectBody': (
    en: '{club} will withdraw and {player} stays at your club.',
    id: '{club} akan mundur dan {player} tetap di klub Anda.',
    fr: '{club} se retirera et {player} restera dans votre club.',
  ),
  'room.cancelBody': (
    en: 'Negotiations for {player} will close. You can bid again later.',
    id: 'Negosiasi untuk {player} ditutup. Anda bisa menawar lagi nanti.',
    fr:
        'La négociation pour {player} sera close. Vous pourrez refaire une offre plus tard.',
  ),
  'room.keepTalking': (
    en: 'Keep talking',
    id: 'Lanjut berunding',
    fr: 'Continuer',
  ),
  'room.rejectOffer': (
    en: 'Reject offer',
    id: 'Tolak tawaran',
    fr: 'Refuser l\'offre',
  ),
  'room.cancelTalks': (
    en: 'Call off negotiation',
    id: 'Batalkan negosiasi',
    fr: 'Annuler la négociation',
  ),
  'room.acceptAmount': (
    en: 'Accept {amount}',
    id: 'Terima {amount}',
    fr: 'Accepter {amount}',
  ),
  'room.history': (
    en: 'History ({n})',
    id: 'Riwayat ({n})',
    fr: 'Historique ({n})',
  ),
  'room.yourOffer': (en: 'Your offer', id: 'Tawaran Anda', fr: 'Votre offre'),
  'room.budget': (en: 'Budget', id: 'Anggaran', fr: 'Budget'),
  'room.preferredYears': (
    en: 'Preferred length',
    id: 'Durasi disukai',
    fr: 'Durée souhaitée',
  ),
  'room.anchorSell': (
    en: 'Buyer\'s offer',
    id: 'Tawaran pembeli',
    fr: 'Offre de l\'acheteur',
  ),
  'room.anchorContract': (
    en: 'Agent\'s wage demand',
    id: 'Gaji diminta agen',
    fr: 'Salaire demandé par l\'agent',
  ),
  'room.anchorBuy': (
    en: 'Agent\'s asking price',
    id: 'Patokan agen',
    fr: 'Prix de l\'agent',
  ),
  'room.hintBuy': (
    en:
        'Paying upfront and a bigger sell-on make the agent lower the price. The figure above already reflects your terms.',
    id:
        'Pembayaran langsung dan sell-on yang lebih besar membuat agen mau menurunkan harga. Patokan di atas sudah menyesuaikan syarat Anda.',
    fr:
        'Payer comptant et une clause de revente plus élevée font baisser le prix. Le montant ci-dessus tient déjà compte de vos conditions.',
  ),
  'room.hintSell': (
    en:
        'Accepting instalments makes the buyer pay a higher amount; asking for a sell-on lowers it.',
    id:
        'Menerima cicilan membuat pembeli mau membayar nominal lebih tinggi; meminta sell-on membuatnya menurunkan nominal.',
    fr:
        'Accepter un paiement échelonné fait monter le montant ; exiger une clause de revente le fait baisser.',
  ),
  'room.hintContract': (
    en:
        'A bigger role and a length that suits the player\'s age make the agent lower the wage.',
    id:
        'Peran yang lebih besar dan durasi yang cocok dengan usia pemain membuat agen mau menurunkan gaji.',
    fr:
        'Un rôle plus important et une durée adaptée à l\'âge du joueur font baisser le salaire.',
  ),
  'room.subjectBuy': (
    en: 'Transfer fee from {club}',
    id: 'Harga transfer dari {club}',
    fr: 'Indemnité réclamée par {club}',
  ),
  'room.subjectSell': (
    en: '{club}\'s offer for your player',
    id: 'Tawaran {club} untuk pemain Anda',
    fr: 'Offre de {club} pour votre joueur',
  ),
  'room.subjectContract': (
    en: 'Player contract, {fee} fee already agreed',
    id: 'Kontrak pemain, harga {fee} sudah disepakati',
    fr: 'Contrat du joueur, indemnité de {fee} déjà convenue',
  ),
  'room.mood.open': (
    en: 'still open to discussion',
    id: 'masih terbuka berdiskusi',
    fr: 'encore ouvert à la discussion',
  ),
  'room.mood.impatient': (
    en: 'getting impatient',
    id: 'mulai tidak sabar',
    fr: 'commence à s\'impatienter',
  ),
  'room.mood.critical': (
    en: 'one wrong move and he leaves',
    id: 'satu langkah salah, ia pergi',
    fr: 'un faux pas et il s\'en va',
  ),
  'room.mood.gone': (en: 'gone', id: 'sudah pergi', fr: 'parti'),
  'room.style': (en: '{style} style', id: 'gaya {style}', fr: 'style {style}'),
  'room.agentShort': (
    en: 'agent, {style}',
    id: 'agen, {style}',
    fr: 'agent, {style}',
  ),
  'room.playerAgent': (
    en: 'Player\'s agent, {style}',
    id: 'Agen pemain, {style}',
    fr: 'Agent du joueur, {style}',
  ),
  'room.patience': (
    en: 'Patience {n}%, {mood}',
    id: 'Kesabaran {n}%, {mood}',
    fr: 'Patience {n} %, {mood}',
  ),
  'room.patienceSemantics': (
    en: 'Agent patience {n} percent',
    id: 'Kesabaran agen {n} persen',
    fr: 'Patience de l\'agent {n} pour cent',
  ),
  'room.wageLabel': (
    en: 'Wage per year ({unit})',
    id: 'Gaji per tahun ({unit})',
    fr: 'Salaire annuel ({unit})',
  ),
  'room.installments': (
    en: 'Over {n} years',
    id: 'Cicil {n} tahun',
    fr: 'Sur {n} ans',
  ),
  'room.sellOnLabel': (
    en: 'Sell-on of next sale',
    id: 'Sell-on penjualan berikutnya',
    fr: 'Clause de revente',
  ),
  'room.contractLength': (
    en: 'Contract length',
    id: 'Durasi kontrak',
    fr: 'Durée du contrat',
  ),
  'room.yearsPreferred': (
    en: '{years} (preferred)',
    id: '{years} (disukai)',
    fr: '{years} (souhaité)',
  ),
  'room.squadRole': (
    en: 'Squad role',
    id: 'Peran di skuad',
    fr: 'Rôle dans l\'effectif',
  ),
  'room.showEarlier': (
    en: 'Show {n} earlier lines',
    id: 'Tampilkan {n} baris sebelumnya',
    fr: 'Afficher {n} lignes précédentes',
  ),
  'room.you': (en: 'You', id: 'Anda', fr: 'Vous'),
  'room.buyerLeft': (
    en: 'The buyer withdrew. The player stays at your club.',
    id: 'Pembeli mundur. Pemain tetap di klub Anda.',
    fr: 'L\'acheteur s\'est retiré. Le joueur reste dans votre club.',
  ),
  'room.cooldownNote': (
    en:
        'This player can only be approached again in a week. His agent will remember the last figure.',
    id:
        'Pemain ini baru bisa ditawar lagi seminggu lagi. Agennya akan mengingat angka terakhir.',
    fr:
        'Ce joueur ne pourra être approché que dans une semaine. Son agent se souviendra du dernier chiffre.',
  ),
  'room.agreed': (en: 'Deal', id: 'Sepakat', fr: 'Accord'),
  'room.agentLeft': (
    en: 'Agent walked out',
    id: 'Agen pergi',
    fr: 'L\'agent est parti',
  ),
  'room.toContract': (
    en: 'Continue to contract',
    id: 'Lanjut ke kontrak',
    fr: 'Passer au contrat',
  ),
};
