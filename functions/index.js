
const firebase = require("firebase-admin"); // importa la libreria de firebase
firebase.initializeApp() // inicializa la app de firebase

const functions = require("firebase-functions");  // require funciona como importar. Importa las funciones de firebase
const firestore = firebase.firestore()

const {
    onDocumentWritten,
    onDocumentCreated,
    onDocumentUpdated,
    onDocumentDeleted,
    Change,
    FirestoreEvent
} = require("firebase-functions/v2/firestore") // importa las funciones de firestore


async function sendNotificationToUser(userId, notification) {
    const tokenDocs = await firestore.collection("fcm_tokens").where("user_id", "==", userId).get() //busco en la coleccion fcm_tokens el token del usuario
    const tokens = tokenDocs.docs.map(doc => doc.id) //lo vuelvo un array de strings (el id del documento es el token)

    functions.logger.info(`Notificación enviada: ${JSON.stringify(notification)}`, {structuredData: true}); //muestra en la consola de firebase el mensaje

    for (const token of tokens) {
        await firebase.messaging().send({ //envia al token la notificaion con el titulo y el cuerpo
            "token": token,
            "notification": notification
        })
    }
}

module.exports.listCreated = onDocumentCreated('task_lists/{id}', async (event) => {
    const data = event.data.data() //event es lo que paso "crear una lista", .data es el documento y .data() es el contenido del documento
    const users = data.users

    const deadline = data.global_deadline

    functions.logger.info(`Lista creada: ${data.name}, usuarios: ${users}, deadline ${deadline}`, {structuredData: true}); //muestra en la consola de firebase el mensaje

    for (const user of users) { //recorre los usuarios con los que esta compartido
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

