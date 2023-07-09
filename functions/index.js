// here https://console.cloud.google.com/cloudscheduler
const firebase = require("firebase-admin"); // importa la libreria de firebase
firebase.initializeApp() // inicializa la app de firebase

const functions = require("firebase-functions");  // require funciona como importar. Importa las funciones de firebase
const firestore = firebase.firestore()
const auth = firebase.auth()

const {
    onDocumentWritten,
    onDocumentCreated,
    onDocumentUpdated,
    onDocumentDeleted,
    Change,
    // FirestoreEvent
} = require("firebase-functions/v2/firestore"); // importa las funciones de firestore
const { onSchedule } = require("firebase-functions/v2/scheduler");


async function sendNotificationToUser(userId, notification) {
    const tokenDocs = await firestore.collection("fcm_tokens").where("user_id", "==", userId).get() //busco en la coleccion fcm_tokens el token del usuario
    const tokens = tokenDocs.docs.map(doc => doc.id) //lo vuelvo un array de strings (el id del documento es el token)

    functions.logger.info(`Notificación enviada: ${JSON.stringify(notification)}`, { structuredData: true }); //muestra en la consola de firebase el mensaje

    for (const token of tokens) {
        try {
            await firebase.messaging().send({ //envia al token la notificaion con el titulo y el cuerpo
                "token": token,
                "notification": notification,
                android: {
                    priority: 'high',
                    notification: {
                        priority: 'high',
                        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                    },
                },

            })
        } catch (error) {
            functions.logger.error(`Error al enviar notificación: ${error}`, { structuredData: true }); //muestra en la consola de firebase el mensaje
            await firebase.firestore().collection("fcm_tokens").doc(token).delete()
        }
    }
}

module.exports.listCreated = onDocumentCreated('task_lists/{id}', async (event) => {
    const data = event.data.data() //event es lo que paso "crear una lista", .data es el documento y .data() es el contenido del documento
    const users = data.users

    const deadline = data.global_deadline

    // Como `print` pero para la cloud function (para debuggear)
    functions.logger.info(`Lista creada: ${data.name}, usuarios: ${users}, deadline ${deadline}`, { structuredData: true }); //muestra en la consola de firebase el mensaje

    for (const user of users) { //recorre los usuarios con los que esta compartido
        await sendNotificationToUser(user, {
            "title": `Nueva lista: ${data.name}`,
            "body": deadline ? `Fecha límite: ${(new Date(deadline)).toLocaleDateString()}` : "Sin fecha límite"
        })
    }
});

module.exports.listTaskCreated = onDocumentCreated('task_lists/{id}/tasks/{taskId}', async (event) => {
    const data = event.data.data()

    // Como `print` pero para la cloud function (para debuggear)
    functions.logger.info(`Tarea creada: ${JSON.stringify(data)}`, { structuredData: true });

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


module.exports.listTaskCompleted = onDocumentUpdated('task_lists/{id}/tasks/{taskId}', async (event) => {
    const after = event.data.after.data()
    const before = event.data.before.data()

    if (before.completed === after.completed || !after.completed) return

    const id = event.params.id
    const taskList = (await firestore.collection("task_lists").doc(id).get()).data()

    // Como `print` pero para la cloud function (para debuggear)
    functions.logger.info(`Tarea completada: ${JSON.stringify(after)} --> ${JSON.stringify(after.title)}`, { structuredData: true });

    const users = taskList.users

    for (const user of users) {
        if (user === after.completed_by) continue

        const userData = await auth.getUser(after.completed_by)

        await sendNotificationToUser(user, {
            "title": `Tarea completada ${after.title} - ${taskList.name}`,
            "body": `Completada por ${userData.displayName}`
        })
    }
});

const dayMs = 24 * 60 * 60 * 1000

function getDateFromDaysFromNow(days) {
    const threeDaysMs = days * dayMs
    const futureDay = new Date(Date.now() + threeDaysMs)
    const day = futureDay.getDate()
    const month = futureDay.getMonth()
    const year = futureDay.getFullYear()
    const date = new Date(year, month, day);
    return date
}

async function getTaskListWithDeadLineAtDaysFromNow(days) {
    const date = getDateFromDaysFromNow(days)
    const taskLists = await firestore.collection("task_lists").where('global_deadline', '<=', date).where('global_deadline', '>', new Date(date.valueOf() + (days - 1) * dayMs)).get()
    return taskLists.docs
}

async function sendAlertToTaskLists(taskLists) {
    for (const taskList of taskLists) {
        const data = taskList.data()
        const deadline = data.global_deadline

        if (!deadline) continue

        if (data.completed_tasks_quantity != data.tasks_quantity) continue

        const users = data.users

        for (const user of users) {
            await sendNotificationToUser(user, {
                "title": `Recordatorio: ${data.name}`,
                "body": `Fecha límite: ${(new Date(deadline)).toLocaleDateString()}`
            })
        }
    }
}

exports.sendNotification3DaysTaskList = onSchedule('every day 12:00', async (context) => {
    const tasklists = await getTaskListWithDeadLineAtDaysFromNow(3)
    await sendAlertToTaskLists(tasklists)
})

exports.sendNotification1DaysTaskList = onSchedule('every day 12:00', async (context) => {
    const tasklists = await getTaskListWithDeadLineAtDaysFromNow(1)
    await sendAlertToTaskLists(tasklists)
})


async function getTasksWithDeadLineAtDaysFromNow(days) {
    const date = getDateFromDaysFromNow(days)
    const tasks = await firestore.collectionGroup("tasks").where('deadline', '<=', date).where('deadline', '>', new Date(date.valueOf() + (days - 1) * dayMs)).get()
    return tasks.docs
}

async function sendAlertToTasks(tasks) {
    for (const task of tasks) {
        const data = task.data()

        if(data.completed) return

        const taskList = (await task.ref.parent.parent.get()).data()

        const users = taskList.users

        for (const user of users) {
            await sendNotificationToUser(user, {
                "title": `Recordatorio: ${data.title}`,
                "body": `Lista: ${taskList.name}`
            })
        }
    }
}


exports.sendNotification3DaysTask = onSchedule('every day 12:00', async (context) => {
    const tasks = await getTasksWithDeadLineAtDaysFromNow(3)
    await sendAlertToTasks(tasks)
})

exports.sendNotification1DaysTask = onSchedule('every day 12:00', async (context) => {
    const tasks = await getTasksWithDeadLineAtDaysFromNow(1)
    await sendAlertToTasks(tasks)
})
