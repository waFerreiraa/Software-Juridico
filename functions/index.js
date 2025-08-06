const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const firestore = admin.firestore();
const messaging = admin.messaging();

exports.enviarNotificacoesProcessos = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async (context) => {
    const snapshot = await firestore.collection("processos").get();

    const hoje = new Date();
    const dataHoje = new Date(
      hoje.getFullYear(),
      hoje.getMonth(),
      hoje.getDate()
    );

    for (const doc of snapshot.docs) {
      const dados = doc.data();
      const dataStr = dados.data; // ex: "20/08/2025"
      const token = dados.fcmToken; // precisa estar salvo no processo

      if (!dataStr || !token) continue;

      const partes = dataStr.split("/");
      if (partes.length !== 3) continue;

      const dataVencimento = new Date(
        parseInt(partes[2]), // ano
        parseInt(partes[1]) - 1, // mês
        parseInt(partes[0]) // dia
      );

      const diffDias = Math.ceil(
        (dataVencimento - dataHoje) / (1000 * 60 * 60 * 24)
      );

      if (diffDias === 10) {
        await messaging.send({
          token,
          notification: {
            title: "Processo próximo do vencimento",
            body: `O processo ${dados.numero} vence em 10 dias.`,
          },
        });
      }
    }

    return null;
  });
