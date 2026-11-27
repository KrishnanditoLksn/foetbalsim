import 'tr_entry.dart';

/// Teks yang dibuat service/engine: komentar laga, pesan error, pesan inbox
/// dan berita bursa (disimpan sebagai `Msg`), alasan penolakan, dialog agen.
const Map<String, Tr> engineStrings = {
  // --- Komentar laga ---
  'ev.kickOff': (
    en: 'Kick-off.',
    id: 'Pertandingan dimulai.',
    fr: 'Coup d\'envoi.',
  ),
  'ev.mentality': (
    en: '{team} switch to a {mentality} mentality.',
    id: '{team} mengubah mentalitas menjadi {mentality}.',
    fr: '{team} passe en mentalité {mentality}.',
  ),
  'ev.substitution': (
    en: '{team} substitution: {in} on, {out} off.',
    id: 'Pergantian {team}: masuk {in}, keluar {out}.',
    fr: 'Changement pour {team} : {in} entre, {out} sort.',
  ),
  'ev.throughBall': (
    en: 'Through ball from {from} to {to}!',
    id: 'Umpan terobosan dari {from} ke {to}!',
    fr: 'Passe en profondeur de {from} pour {to} !',
  ),
  'ev.cross': (
    en: '{from} crosses to {to} in the box.',
    id: 'Umpan silang {from} ke {to} di kotak penalti.',
    fr: 'Centre de {from} pour {to} dans la surface.',
  ),
  'ev.miss1': (
    en: '{p}\'s shot goes wide.',
    id: 'Tembakan {p} melebar.',
    fr: 'La frappe de {p} passe à côté.',
  ),
  'ev.miss2': (
    en: '{p} blazes it over the bar.',
    id: 'Tembakan {p} melambung di atas mistar.',
    fr: '{p} envoie le ballon au-dessus.',
  ),
  'ev.miss3': (
    en: '{p}\'s effort flashes just past the post.',
    id: 'Sepakan {p} meleset tipis di samping gawang.',
    fr: 'La tentative de {p} frôle le poteau.',
  ),
  'ev.hitBar': (
    en: '{p}\'s shot hits the bar!',
    id: 'Tembakan {p} membentur mistar!',
    fr: 'La frappe de {p} heurte la barre !',
  ),
  'ev.gltGoal': (
    en: 'GOAL-LINE TECH: GOAL',
    id: 'GOAL-LINE TECH: GOL',
    fr: 'GOAL-LINE TECHNOLOGY : BUT',
  ),
  'ev.gltNoGoal': (
    en: 'GOAL-LINE TECH: NOT OVER THE LINE',
    id: 'GOAL-LINE TECH: BELUM MELEWATI GARIS',
    fr: 'GOAL-LINE TECHNOLOGY : PAS ENTIÈREMENT RENTRÉ',
  ),
  'ev.reboundCaught': (
    en: 'It bounces out, {gk} gathers.',
    id: 'Bola memantul, ditangkap {gk}.',
    fr: 'Le ballon rebondit, {gk} s\'en empare.',
  ),
  'ev.save': (
    en: 'Save by {gk}! {p}\'s shot is parried.',
    id: 'Penyelamatan {gk}! Tembakan {p} ditepis.',
    fr: 'Arrêt de {gk} ! La frappe de {p} est repoussée.',
  ),
  'ev.goal': (
    en: 'GOAL! {p} — {score}.',
    id: 'GOOL! {p} — {score}.',
    fr: 'BUT ! {p} — {score}.',
  ),
  'ev.goalAssist': (
    en: 'GOAL! {p} (assist: {a}) — {score}.',
    id: 'GOOL! {p} (assist: {a}) — {score}.',
    fr: 'BUT ! {p} (passe décisive : {a}) — {score}.',
  ),
  'ev.varPenalty': (
    en: 'penalty for {p}',
    id: 'penalti untuk {p}',
    fr: 'penalty pour {p}',
  ),
  'ev.penalty': (
    en: 'PENALTY! {p} steps up.',
    id: 'PENALTI! {p} maju ke titik penalti.',
    fr: 'PENALTY ! {p} s\'avance.',
  ),
  'ev.penaltySaved': (
    en: 'Penalty saved by {gk}!',
    id: 'Penalti ditepis {gk}!',
    fr: 'Penalty arrêté par {gk} !',
  ),
  'ev.foul': (
    en: 'Foul by {p}.',
    id: 'Pelanggaran oleh {p}.',
    fr: 'Faute de {p}.',
  ),
  'ev.varStraightRed': (
    en: 'straight red card for {p}',
    id: 'kartu merah langsung untuk {p}',
    fr: 'carton rouge direct pour {p}',
  ),
  'ev.straightRed': (
    en: 'Straight red! {p} denied a clear goal-scoring chance.',
    id: 'Kartu merah langsung! {p} menggagalkan peluang emas.',
    fr: 'Rouge direct ! {p} a annulé une occasion nette.',
  ),
  'ev.yellow': (
    en: 'Yellow card for {p}.',
    id: 'Kartu kuning untuk {p}.',
    fr: 'Carton jaune pour {p}.',
  ),
  'ev.varRed': (
    en: 'red card for {p}',
    id: 'kartu merah untuk {p}',
    fr: 'carton rouge pour {p}',
  ),
  'ev.secondYellow': (
    en: 'Red card! {p} is sent off (second yellow).',
    id: 'Kartu merah! {p} diusir (dua kuning).',
    fr: 'Carton rouge ! {p} est expulsé (deuxième jaune).',
  ),
  'ev.dive': (
    en: '{p} goes down in the box — a dive!',
    id: '{p} menjatuhkan diri di kotak penalti!',
    fr: '{p} se laisse tomber dans la surface !',
  ),
  'ev.offside': (
    en: 'OFFSIDE! {p} was in an offside position.',
    id: 'OFFSIDE! {p} berada di posisi offside.',
    fr: 'HORS-JEU ! {p} était en position de hors-jeu.',
  ),
  'ev.varReview': (
    en: 'VAR REVIEW: {subject}.',
    id: 'PENINJAUAN VAR: {subject}.',
    fr: 'VAR : vérification, {subject}.',
  ),
  'ev.varOverturned': (
    en: 'VAR: decision overturned.',
    id: 'VAR: keputusan dibatalkan.',
    fr: 'VAR : décision annulée.',
  ),
  'ev.varStands': (
    en: 'VAR: decision stands.',
    id: 'VAR: keputusan dipertahankan.',
    fr: 'VAR : décision maintenue.',
  ),
  'ev.halfTime': (
    en: 'Half-time. Score {score}.',
    id: 'Turun minum. Skor {score}.',
    fr: 'Mi-temps. Score {score}.',
  ),
  'ev.fullTime': (
    en: 'Full-time. Final score {score}.',
    id: 'Peluit akhir. Skor akhir {score}.',
    fr: 'Coup de sifflet final. Score final {score}.',
  ),

  // --- Pesan error ---
  'err.noCareer': (
    en: 'This save has no career data yet.',
    id: 'Save belum berisi data karier.',
    fr: 'Cette sauvegarde ne contient pas encore de carrière.',
  ),
  'err.noActiveSave': (
    en: 'No active save. Open or create a career first.',
    id: 'Belum ada save aktif. Buka atau buat karier dulu.',
    fr: 'Aucune sauvegarde active. Ouvrez ou créez une carrière.',
  ),
  'err.noMatchToday': (
    en: 'Your team has no match today.',
    id: 'Tidak ada laga tim Anda hari ini.',
    fr: 'Votre équipe ne joue pas aujourd\'hui.',
  ),
  'err.matchNotFound': (
    en: 'Match not found.',
    id: 'Laga tidak ditemukan.',
    fr: 'Match introuvable.',
  ),
  'err.matchAlreadyPlayed': (
    en: 'This match has already been played.',
    id: 'Laga ini sudah dimainkan.',
    fr: 'Ce match a déjà été joué.',
  ),
  'err.matchFinished': (
    en: 'The match is over.',
    id: 'Laga sudah selesai.',
    fr: 'Le match est terminé.',
  ),
  'err.matchNotFinished': (
    en: 'The match isn\'t over yet.',
    id: 'Laga belum selesai.',
    fr: 'Le match n\'est pas terminé.',
  ),
  'err.subWindowsUsed': (
    en: 'All substitution windows ({n}) have been used.',
    id: 'Kesempatan pergantian ({n}) sudah habis.',
    fr: 'Toutes les fenêtres de changement ({n}) ont été utilisées.',
  ),
  'err.openSubWindow': (
    en: 'Open a substitution window first.',
    id: 'Buka kesempatan pergantian dulu.',
    fr: 'Ouvrez d\'abord une fenêtre de changement.',
  ),
  'err.subsUsed': (
    en: 'The limit of {n} substitutions has been reached.',
    id: 'Batas {n} pergantian sudah habis.',
    fr: 'La limite de {n} changements est atteinte.',
  ),
  'err.subOutNotOnPitch': (
    en: 'The outgoing player is not on the pitch.',
    id: 'Pemain keluar tidak di lapangan.',
    fr: 'Le joueur sortant n\'est pas sur le terrain.',
  ),
  'err.subInNotOnBench': (
    en: 'The incoming player is not on the bench.',
    id: 'Pemain masuk tidak ada di bangku cadangan.',
    fr: 'Le joueur entrant n\'est pas sur le banc.',
  ),
  'err.playerNotFound': (
    en: 'Player not found.',
    id: 'Pemain tidak ditemukan.',
    fr: 'Joueur introuvable.',
  ),
  'err.clubNotFound': (
    en: 'Club not found.',
    id: 'Klub tidak ditemukan.',
    fr: 'Club introuvable.',
  ),
  'err.windowClosed': (
    en: 'The transfer window is closed.',
    id: 'Jendela transfer sedang tertutup.',
    fr: 'Le mercato est fermé.',
  ),
  'err.alreadyOurs': (
    en: 'This player is already at your club.',
    id: 'Pemain ini sudah bersama klub Anda.',
    fr: 'Ce joueur est déjà dans votre club.',
  ),
  'err.playerLocked': (
    en: 'This player just moved clubs and is locked until the next window.',
    id: 'Pemain baru pindah klub dan terkunci sampai jendela berikutnya.',
    fr:
        'Ce joueur vient d\'être transféré et est bloqué jusqu\'au prochain mercato.',
  ),
  'err.alreadyNegotiating': (
    en: 'A negotiation for this player is already under way.',
    id: 'Sudah ada negosiasi berjalan untuk pemain ini.',
    fr: 'Une négociation est déjà en cours pour ce joueur.',
  ),
  'err.agentCooldown': (
    en:
        '{player}\'s agent ended the last negotiation. He won\'t talk again until {date}.',
    id:
        'Agen {player} mengakhiri negosiasi terakhir. Ia baru mau bicara lagi mulai {date}.',
    fr:
        'L\'agent de {player} a mis fin à la dernière négociation. Il ne reparlera pas avant le {date}.',
  ),
  'err.squadFullSell': (
    en: 'Squad is full (max {max} players). Sell a player first.',
    id: 'Skuad penuh (maks {max} pemain). Jual pemain dulu.',
    fr: 'Effectif complet ({max} joueurs max). Vendez d\'abord un joueur.',
  ),
  'err.squadFull': (
    en: 'Squad is full (max {max} players).',
    id: 'Skuad penuh (maks {max} pemain).',
    fr: 'Effectif complet ({max} joueurs max).',
  ),
  'err.squadMin': (
    en: 'The squad needs at least {min} players. Sign a player first.',
    id: 'Skuad minimal {min} pemain. Rekrut pemain dulu.',
    fr: 'L\'effectif doit compter au moins {min} joueurs. Recrutez d\'abord.',
  ),
  'err.maxIncoming': (
    en: 'Limit of {n} incoming players per window reached.',
    id: 'Batas {n} pemain masuk per jendela tercapai.',
    fr: 'Limite de {n} arrivées par mercato atteinte.',
  ),
  'err.maxOutgoing': (
    en: 'Limit of {n} outgoing players per window reached.',
    id: 'Batas {n} pemain keluar per jendela tercapai.',
    fr: 'Limite de {n} départs par mercato atteinte.',
  ),
  'err.budget': (
    en: 'Not enough transfer budget ({left} left).',
    id: 'Anggaran transfer tidak cukup (sisa {left}).',
    fr: 'Budget transferts insuffisant (reste {left}).',
  ),
  'err.balance': (
    en: 'Club balance can\'t cover the upfront payment of {upfront}.',
    id: 'Saldo klub tidak cukup untuk pembayaran di muka {upfront}.',
    fr: 'Le solde du club ne couvre pas le paiement initial de {upfront}.',
  ),
  'err.amountPositive': (
    en: 'The amount must be greater than zero.',
    id: 'Nominal harus lebih dari nol.',
    fr: 'Le montant doit être supérieur à zéro.',
  ),
  'err.installments': (
    en: 'Instalments can only be upfront, 2 or 3 years.',
    id: 'Cicilan hanya bisa langsung, 2, atau 3 tahun.',
    fr: 'Paiement comptant, sur 2 ou 3 ans uniquement.',
  ),
  'err.sellOn': (
    en: 'Sell-on clause must be 0% or 10–30%.',
    id: 'Sell-on clause hanya 0% atau 10–30%.',
    fr: 'Clause de revente : 0 % ou 10–30 % uniquement.',
  ),
  'err.negotiationInactive': (
    en: 'This negotiation is no longer active.',
    id: 'Negosiasi ini sudah tidak berjalan.',
    fr: 'Cette négociation n\'est plus active.',
  ),
  'err.negotiationOver': (
    en: 'This negotiation is over.',
    id: 'Negosiasi ini sudah selesai.',
    fr: 'Cette négociation est terminée.',
  ),
  'err.useRoom': (
    en: 'Bargain in the Negotiation Room.',
    id: 'Tawar harga di Ruang Negosiasi.',
    fr: 'Négociez dans la salle de négociation.',
  ),
  'err.awaitingSeller': (
    en: 'Waiting for the selling club to respond.',
    id: 'Menunggu respons klub penjual.',
    fr: 'En attente de la réponse du club vendeur.',
  ),
  'err.anchorChanged': (
    en: 'The agent\'s figure changed. Try again.',
    id: 'Patokan agen berubah. Coba lagi.',
    fr: 'Le chiffre de l\'agent a changé. Réessayez.',
  ),
  'err.contractYears': (
    en: 'Contract length must be 1–5 years.',
    id: 'Durasi kontrak 1–5 tahun.',
    fr: 'Durée du contrat : 1 à 5 ans.',
  ),
  'err.wageAndYears': (
    en: 'Enter a wage (above zero) and a length of 1–5 years.',
    id: 'Isi gaji (lebih dari nol) dan durasi 1–5 tahun.',
    fr: 'Saisissez un salaire (supérieur à zéro) et une durée de 1 à 5 ans.',
  ),

  // --- Pesan inbox (disimpan sebagai Msg) ---
  'msg.boardWelcome.title': (
    en: 'Welcome from the board',
    id: 'Sambutan dewan',
    fr: 'Mot de bienvenue de la direction',
  ),
  'msg.boardWelcome.body': (
    en:
        'Welcome to {club}, Manager {manager}. This season\'s target: finish {target, ordinal} or better. Accept the target to start the season.',
    id:
        'Selamat datang di {club}, Manajer {manager}. Target musim ini: finis di posisi {target} atau lebih baik. Terima target ini untuk memulai musim.',
    fr:
        'Bienvenue à {club}, coach {manager}. Objectif de la saison : finir {target}e ou mieux. Acceptez l\'objectif pour lancer la saison.',
  ),
  'msg.result.title': (
    en: 'Result: {score}',
    id: 'Hasil: {score}',
    fr: 'Résultat : {score}',
  ),
  'msg.result.body': (
    en:
        '{scorers} Possession {possession}. Shots {shots} (on target {onTarget}). Squad morale {morale} ({delta}).',
    id:
        '{scorers} Penguasaan bola {possession}. Tembakan {shots} (tepat sasaran {onTarget}). Moral skuad {morale} ({delta}).',
    fr:
        '{scorers} Possession {possession}. Tirs {shots} (cadrés {onTarget}). Moral de l\'effectif {morale} ({delta}).',
  ),
  'msg.result.noGoals': (en: 'No goals.', id: 'Tanpa gol.', fr: 'Aucun but.'),
  'msg.result.moraleUp': (en: 'up', id: 'naik', fr: 'en hausse'),
  'msg.result.moraleDown': (en: 'down', id: 'turun', fr: 'en baisse'),
  'msg.result.moraleSame': (en: 'unchanged', id: 'tetap', fr: 'stable'),
  'msg.scout.title': (
    en: 'Opposition report: {club}',
    id: 'Laporan lawan: {club}',
    fr: 'Rapport sur l\'adversaire : {club}',
  ),
  'msg.scout.bodyHome': (
    en:
        'Home match tomorrow. {club} are {pos, ordinal} with {points} points. Recent form: {form}. Key player: {player} (CA {ca}).',
    id:
        'Laga kandang besok. {club} di posisi {pos} dengan {points} poin. Bentuk terakhir: {form}. Pemain kunci: {player} (CA {ca}).',
    fr:
        'Match à domicile demain. {club} est {pos}e avec {points} points. Forme récente : {form}. Joueur clé : {player} (CA {ca}).',
  ),
  'msg.scout.bodyAway': (
    en:
        'Away match tomorrow. {club} are {pos, ordinal} with {points} points. Recent form: {form}. Key player: {player} (CA {ca}).',
    id:
        'Laga tandang besok. {club} di posisi {pos} dengan {points} poin. Bentuk terakhir: {form}. Pemain kunci: {player} (CA {ca}).',
    fr:
        'Match à l\'extérieur demain. {club} est {pos}e avec {points} points. Forme récente : {form}. Joueur clé : {player} (CA {ca}).',
  ),
  'msg.expiry.title': (
    en: '{player}\'s contract is about to expire',
    id: 'Kontrak {player} segera berakhir',
    fr: 'Le contrat de {player} arrive à échéance',
  ),
  'msg.expiry.body': (
    en:
        'The contract ends on 30 June {year}. Current wage {wage}/yr. Renew for 2 years with a 10% raise, or let him go.',
    id:
        'Kontrak berakhir 30 Juni {year}. Gaji saat ini {wage}/tahun. Perpanjang 2 tahun dengan kenaikan gaji 10%, atau biarkan pergi.',
    fr:
        'Le contrat se termine le 30 juin {year}. Salaire actuel {wage}/an. Prolongez de 2 ans avec 10 % d\'augmentation, ou laissez-le partir.',
  ),
  'msg.seasonEnd.title': (
    en: 'Season over',
    id: 'Musim selesai',
    fr: 'Saison terminée',
  ),
  'msg.seasonEnd.body': (
    en:
        'Final position {pos} of {teams} with {points} points ({won}W {drawn}D {lost}L). Board target: {target, ordinal}. {verdict}',
    id:
        'Posisi akhir {pos} dari {teams} dengan {points} poin ({won}M {drawn}S {lost}K). Target dewan: posisi {target}. {verdict}',
    fr:
        'Classement final {pos}e sur {teams} avec {points} points ({won}G {drawn}N {lost}P). Objectif de la direction : {target}e. {verdict}',
  ),
  'msg.seasonEnd.targetMet': (
    en: 'Target achieved.',
    id: 'Target tercapai.',
    fr: 'Objectif atteint.',
  ),
  'msg.seasonEnd.targetMissed': (
    en: 'Target missed.',
    id: 'Target belum tercapai.',
    fr: 'Objectif manqué.',
  ),
  'msg.bidSent.title': (
    en: 'Offer sent: {player}',
    id: 'Tawaran dikirim: {player}',
    fr: 'Offre envoyée : {player}',
  ),
  'msg.bidSent.body': (
    en:
        'Your {terms} offer for {player} was sent to {club}. Response within {days, plural, one{# day} other{# days}}.',
    id:
        'Tawaran {terms} untuk {player} dikirim ke {club}. Respons dalam {days} hari.',
    fr:
        'Votre offre de {terms} pour {player} a été envoyée à {club}. Réponse sous {days, plural, one{# jour} other{# jours}}.',
  ),
  'msg.sellerAccepted': (
    en: '{club} accepted the {terms} offer.',
    id: '{club} menerima tawaran {terms}.',
    fr: '{club} a accepté l\'offre de {terms}.',
  ),
  'msg.counter.title': (
    en: 'Counter-offer: {player}',
    id: 'Kontra-tawaran: {player}',
    fr: 'Contre-offre : {player}',
  ),
  'msg.counter.body': (
    en:
        '{club} haven\'t agreed to the {terms} offer for {player}. His agent, {agent}, is waiting for you in the Negotiation Room to discuss the fee.',
    id:
        '{club} belum setuju dengan tawaran {terms} untuk {player}. Agennya, {agent}, menunggu Anda di Ruang Negosiasi untuk membahas harga.',
    fr:
        '{club} n\'accepte pas l\'offre de {terms} pour {player}. Son agent, {agent}, vous attend dans la salle de négociation pour discuter du montant.',
  ),
  'msg.rejected.title': (
    en: 'Offer rejected: {player}',
    id: 'Tawaran ditolak: {player}',
    fr: 'Offre refusée : {player}',
  ),
  'msg.rejected.body': (
    en: '{club} rejected the {terms} offer. {reason}',
    id: '{club} menolak tawaran {terms}. {reason}',
    fr: '{club} a refusé l\'offre de {terms}. {reason}',
  ),
  'msg.feeAgreed.title': (
    en: 'Fee agreed: {player}',
    id: 'Harga disepakati: {player}',
    fr: 'Montant convenu : {player}',
  ),
  'msg.feeAgreed.body': (
    en:
        '{lead} {player}\'s agent is waiting in the Negotiation Room to discuss wage, length and squad role.',
    id:
        '{lead} Agen {player} menunggu di Ruang Negosiasi untuk membahas gaji, durasi, dan peran di skuad.',
    fr:
        '{lead} L\'agent de {player} vous attend dans la salle de négociation pour parler salaire, durée et rôle.',
  ),
  'msg.agreedWithAgent': (
    en: 'You and agent {agent} agreed on {terms}.',
    id: 'Anda dan agen {agent} sepakat di {terms}.',
    fr: 'Vous et l\'agent {agent} vous êtes entendus sur {terms}.',
  ),
  'msg.failed.title': (
    en: 'Negotiation failed: {player}',
    id: 'Negosiasi gagal: {player}',
    fr: 'Négociation échouée : {player}',
  ),
  'msg.failed.buyerLeft': (
    en: '{club} pulled out of the negotiation for {player}.',
    id: '{club} mundur dari negosiasi untuk {player}.',
    fr: '{club} s\'est retiré de la négociation pour {player}.',
  ),
  'msg.failed.cooldown': (
    en: '{reason} {player} can only be approached again in a week.',
    id: '{reason} {player} baru bisa ditawar lagi seminggu lagi.',
    fr: '{reason} {player} ne pourra être approché que dans une semaine.',
  ),
  'msg.completed.title': (
    en: 'Transfer completed: {player}',
    id: 'Transfer selesai: {player}',
    fr: 'Transfert conclu : {player}',
  ),
  'msg.completed.body': (
    en: '{player} moves from {from} to {to} for {terms}.',
    id: '{player} pindah dari {from} ke {to} dengan {terms}.',
    fr: '{player} passe de {from} à {to} pour {terms}.',
  ),
  'msg.incoming.title': (
    en: 'Incoming offer: {player}',
    id: 'Tawaran masuk: {player}',
    fr: 'Offre reçue : {player}',
  ),
  'msg.incoming.body': (
    en:
        '{club} bid {fee} for {player}. Accept, reject, or bargain through the player\'s agent in the Negotiation Room.',
    id:
        '{club} menawar {player} dengan {fee}. Terima, tolak, atau tawar harga lewat agen pemain di Ruang Negosiasi.',
    fr:
        '{club} propose {fee} pour {player}. Acceptez, refusez ou négociez via l\'agent du joueur dans la salle de négociation.',
  ),
  'msg.incoming.bodyUnlisted': (
    en:
        '{club} bid {fee} for {player} (not on the transfer list). Accept, reject, or bargain through the player\'s agent in the Negotiation Room.',
    id:
        '{club} menawar {player} dengan {fee} (pemain tidak didaftar jual). Terima, tolak, atau tawar harga lewat agen pemain di Ruang Negosiasi.',
    fr:
        '{club} propose {fee} pour {player} (pas sur la liste des transferts). Acceptez, refusez ou négociez via l\'agent du joueur dans la salle de négociation.',
  ),
  'msg.playerOffered.title': (
    en: 'Player offered: {player}',
    id: 'Tawaran pemain: {player}',
    fr: 'Joueur proposé : {player}',
  ),
  'msg.playerOffered.body': (
    en: '{text} Find him in Player Search to make a bid.',
    id: '{text} Cari pemain ini di Cari Pemain untuk menawar.',
    fr: '{text} Retrouvez-le dans la recherche pour faire une offre.',
  ),
  'msg.windowClosed.title': (
    en: 'Window closed',
    id: 'Bursa ditutup',
    fr: 'Mercato clos',
  ),
  'msg.windowClosed.body': (
    en:
        'The transfer window has closed: {n} transfers in the league. Unfinished negotiations were called off.',
    id:
        'Bursa transfer ditutup: {n} transfer di liga. Negosiasi yang belum tuntas dibatalkan.',
    fr:
        'Le mercato est clos : {n} transferts dans la ligue. Les négociations en cours ont été annulées.',
  ),

  // --- Berita bursa (disimpan sebagai Msg) ---
  'news.deadlineDay': (
    en: 'DEADLINE DAY is here: the market at its hottest.',
    id: 'DEADLINE DAY dimulai: pasar paling panas.',
    fr: 'Le DEADLINE DAY commence : le marché s\'emballe.',
  ),
  'news.rumour': (
    en: '{club} are monitoring {player} ({pos}).',
    id: '{club} memantau {player} ({pos}).',
    fr: '{club} surveille {player} ({pos}).',
  ),
  'news.deal': (
    en: '{seller} sell {player} to {buyer} for {fee}.',
    id: '{seller} menjual {player} ke {buyer} seharga {fee}.',
    fr: '{seller} vend {player} à {buyer} pour {fee}.',
  ),
  'news.offer': (
    en: '{club} are offering {player} ({pos}, {age} y/o) for {fee}.',
    id: '{club} menawarkan {player} ({pos}, {age} th) seharga {fee}.',
    fr: '{club} propose {player} ({pos}, {age} ans) pour {fee}.',
  ),
  'news.closed': (
    en: 'Window closed: {n} transfers.',
    id: 'Bursa ditutup: {n} transfer.',
    fr: 'Mercato clos : {n} transferts.',
  ),
  'news.closedBiggest': (
    en: 'Window closed: {n} transfers, biggest {fee} ({player}).',
    id: 'Bursa ditutup: {n} transfer, terbesar {fee} ({player}).',
    fr: 'Mercato clos : {n} transferts, le plus gros {fee} ({player}).',
  ),

  // --- Alasan penolakan (disimpan sebagai Msg) ---
  'reason.indispensable': (
    en: 'Key player, not for sale below {fee}.',
    id: 'Pemain inti, tidak dijual di bawah {fee}.',
    fr: 'Joueur clé, pas à vendre sous {fee}.',
  ),
  'reason.tooLow': (
    en: 'The offer is too low.',
    id: 'Tawaran terlalu rendah.',
    fr: 'Offre trop basse.',
  ),
  'reason.rejected': (
    en: 'Offer rejected.',
    id: 'Tawaran ditolak.',
    fr: 'Offre refusée.',
  ),
  'reason.shortContract': (
    en: '≤ 6 months left on his contract: waiting to leave on a free.',
    id: 'Kontrak tinggal ≤ 6 bulan: menunggu bebas transfer.',
    fr: 'Moins de 6 mois de contrat : il attend de partir libre.',
  ),
  'reason.movingDown': (
    en: '{player} won\'t step down a level without a pay rise.',
    id: '{player} tidak mau turun kelas tanpa kenaikan gaji.',
    fr: '{player} refuse de descendre d\'un niveau sans augmentation.',
  ),
  'reason.wageRefused': (
    en: '{player} turned down the wage offered.',
    id: '{player} menolak gaji yang ditawarkan.',
    fr: '{player} a refusé le salaire proposé.',
  ),
  'reason.contractRefused': (
    en:
        '{player} rejected a {wage}/yr contract. He wants at least {expected}/yr.',
    id:
        '{player} menolak kontrak {wage}/tahun. Ia menginginkan minimal {expected}/tahun.',
    fr:
        '{player} a refusé un contrat à {wage}/an. Il veut au moins {expected}/an.',
  ),
  'reason.playerMoved': (
    en: 'The player has already moved clubs.',
    id: 'Pemain sudah pindah klub.',
    fr: 'Le joueur a déjà changé de club.',
  ),
  'reason.cancelledByUs': (
    en: 'Called off by your club.',
    id: 'Dibatalkan oleh klub Anda.',
    fr: 'Annulé par votre club.',
  ),
  'reason.rejectedByUs': (
    en: 'Rejected by your club.',
    id: 'Ditolak oleh klub Anda.',
    fr: 'Refusé par votre club.',
  ),
  'reason.agentWalkedOut': (
    en: 'Agent {agent} ended the negotiation.',
    id: 'Agen {agent} mengakhiri negosiasi.',
    fr: 'L\'agent {agent} a mis fin à la négociation.',
  ),

  // --- Hasil langkah negosiasi ---
  'step.feeAgreed': (
    en: 'Fee agreed. On to the contract.',
    id: 'Harga disepakati. Lanjut ke kontrak.',
    fr: 'Montant convenu. Place au contrat.',
  ),
  'step.playerSold': (
    en: 'Player sold.',
    id: 'Pemain dijual.',
    fr: 'Joueur vendu.',
  ),
  'step.joined': (
    en: '{player} has officially joined.',
    id: '{player} resmi bergabung.',
    fr: '{player} a officiellement signé.',
  ),

  // --- Syarat tawaran ---
  'terms.installments': (
    en: '{n}-yr instalments',
    id: 'cicilan {n} thn',
    fr: 'échelonné sur {n} ans',
  ),
  'terms.sellOn': (
    en: 'sell-on {pct}%',
    id: 'sell-on {pct}%',
    fr: 'revente {pct} %',
  ),
  'terms.withExtras': (
    en: '{fee} ({extras})',
    id: '{fee} ({extras})',
    fr: '{fee} ({extras})',
  ),

  // --- Minat klub ---
  'interest.target': (
    en: 'Top target',
    id: 'Target utama',
    fr: 'Cible prioritaire',
  ),
  'interest.interested': (en: 'Interested', id: 'Tertarik', fr: 'Intéressé'),
  'interest.watching': (en: 'Monitoring', id: 'Memantau', fr: 'Surveille'),

  // --- Dialog agen (riwayat disimpan sebagai Msg) ---
  'agent.remembered': (
    en:
        'We stopped at {terms} last time. I haven\'t forgotten, so we start from there.',
    id:
        'Kita pernah berhenti di {terms}. Saya belum lupa, jadi kita mulai dari sana.',
    fr:
        'Nous nous étions arrêtés à {terms}. Je n\'ai pas oublié, alors on reprend de là.',
  ),
  'agent.userOpening': (
    en: 'Your opening offer: {terms}.',
    id: 'Tawaran awal Anda: {terms}.',
    fr: 'Votre offre initiale : {terms}.',
  ),
  'agent.userOffer': (
    en: 'You offer {terms}.',
    id: 'Anda menawarkan {terms}.',
    fr: 'Vous proposez {terms}.',
  ),
  'agent.accept': (
    en: 'Those terms work. We agree to this deal.',
    id: 'Syaratnya cocok. Kami setuju dengan kesepakatan ini.',
    fr: 'Ces conditions nous conviennent. Nous acceptons l\'accord.',
  ),
  'agent.walkOut': (
    en:
        'It looks like we won\'t find common ground. We\'re ending the negotiation.',
    id:
        'Sepertinya kita tidak akan menemukan titik temu. Kami mengakhiri negosiasi.',
    fr:
        'Nous ne trouverons visiblement pas de terrain d\'entente. Nous mettons fin à la négociation.',
  ),
  'agent.termsContract': (
    en: '{wage}/yr for {years, plural, one{# year} other{# years}} as {role}',
    id: '{wage}/tahun selama {years} tahun sebagai {role}',
    fr: '{wage}/an pendant {years, plural, one{# an} other{# ans}} comme {role}',
  ),
  'agent.termsInstallments': (
    en: '{fee} over {n} yrs',
    id: '{fee} dicicil {n} thn',
    fr: '{fee} sur {n} ans',
  ),
  'agent.termsSellOn': (
    en: '{head}, sell-on {pct}%',
    id: '{head}, sell-on {pct}%',
    fr: '{head}, revente {pct} %',
  ),
  'agent.openBuy': (
    en: 'My client is interested, but {club} want {terms} to let {player} go.',
    id:
        'Klien saya tertarik, tapi {club} mematok {terms} untuk melepas {player}.',
    fr:
        'Mon client est intéressé, mais {club} demande {terms} pour laisser partir {player}.',
  ),
  'agent.openSell': (
    en:
        '{club} are offering {terms} for {player}. My client wants to know your number.',
    id:
        '{club} menawarkan {terms} untuk {player}. Klien saya ingin tahu angka Anda.',
    fr:
        '{club} propose {terms} pour {player}. Mon client veut connaître votre prix.',
  ),
  'agent.openContract': (
    en: '{player} is ready to join for {terms}.',
    id: '{player} siap bergabung dengan {terms}.',
    fr: '{player} est prêt à signer pour {terms}.',
  ),
  'agent.lowballSell': (
    en: '{amount} is too high for {club}. Please name a realistic figure.',
    id:
        '{amount} terlalu tinggi bagi {club}. Tolong ajukan angka yang realistis.',
    fr: '{amount}, c\'est trop pour {club}. Proposez un chiffre réaliste.',
  ),
  'agent.lowball': (
    en:
        'An offer of {amount} is far from my client\'s value. Please make a more serious offer.',
    id:
        'Tawaran {amount} terlalu jauh dari nilai klien saya. Tolong ajukan angka yang lebih serius.',
    fr:
        'Une offre de {amount} est loin de la valeur de mon client. Faites une offre plus sérieuse.',
  ),
  'agent.counterSellOpen': (
    en: '{club} can go up to {terms}. How does that sound?',
    id: '{club} bisa naik ke {terms}. Bagaimana?',
    fr: '{club} peut monter à {terms}. Qu\'en dites-vous ?',
  ),
  'agent.counterOpen': (
    en: 'Your figure is still a little off. How about we meet at {terms}?',
    id: 'Angka Anda masih sedikit jauh. Bagaimana jika kita bertemu di {terms}?',
    fr:
        'Votre chiffre est encore un peu loin. Et si on se retrouvait à {terms} ?',
  ),
  'agent.counterImpatient': (
    en: 'Our patience is wearing thin. {terms}, and we can wrap this up today.',
    id: 'Kesabaran kami mulai menipis. {terms}, dan kita bisa selesai hari ini.',
    fr: 'Notre patience s\'épuise. {terms}, et on conclut aujourd\'hui.',
  ),
  'agent.counterFinal': (
    en: 'We don\'t have much time. {terms} is our final figure.',
    id: 'Kami tidak punya banyak waktu. {terms} adalah angka terakhir kami.',
    fr:
        'Nous n\'avons plus beaucoup de temps. {terms}, c\'est notre dernier mot.',
  ),
};
