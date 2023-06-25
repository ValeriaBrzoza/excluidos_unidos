
const firebase = require("firebase-admin");
firebase.initializeApp()

const functions = require("firebase-functions");  // require funciona como importar. Importa las funciones de firebase
const firestore = firebase.firestore()

const {
    onDocumentWritten,
    onDocumentCreated,
    onDocumentUpdated,
    onDocumentDeleted,
    Change,
    FirestoreEvent
} = require("firebase-functions/v2/firestore")


module.exports.listCreated = onDocumentCreated('task_lists/{id}', async (event) => {
    const data = event.data.data()
    const users = data.users

    const deadline = data.global_deadline

    functions.logger.info(`Lista creada: ${data.name}, usuarios: ${users}, deadline ${JSON.stringify(deadline)}`, {structuredData: true});

    for (const user of users) {
        await sendNotificationToUser(user, {
            "title": `Nueva lista: ${data.name}`,
            "body": deadline ? `Fecha límite: ${(new Date(deadline)).toLocaleDateString()}` : "Sin fecha límite"
        })
    }
});

module.exports.listTaskCreated = onDocumentCreated('task_lists/{id}/tasks/{taskId}', async (event) => {
    const data = event.data.data()

    functions.logger.info(`Tarea creada: ${JSON.stringify(data)}`, {structuredData: true});

    const id = event.params.id
    const taskList = (await firestore.collection("task_lists").doc(id).get()).data()

    const users = taskList.users

    for (const user of users) {
        await sendNotificationToUser(user, {
            "title": `Nueva tarea: ${data.title}`,
            "body": `Lista: ${taskList.name}`
        })
    }
});


async function sendNotificationToUser(userId, notification) {
    const tokenDocs = await firestore.collection("fcm_tokens").where("user_id", "==", userId).get()
    const tokens = tokenDocs.docs.map(doc => doc.id)

    functions.logger.info(`Notificación enviada: ${JSON.stringify(notification)}`, {structuredData: true});

    for (const token of tokens) {
        await firebase.messaging().send({ //envia al token la notificaion con el titulo y el cuerpo
            "token": token,
            "notification": notification
        })
    }
}
