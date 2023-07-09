/**
 * - Lista de tareas creada
 * - Lista compartida con más usuarios
 * - Tarea creada
 * - Tarea completada
 * - Tarea asignada a un usuario
 * - Lista de tareas está por vencer en un día
 * - Lista de tareas está por vencer en tres días
 * - Tarea está por vencer en un día
 * - Tarea está por vencer en tres días
 */

const firebase = require("firebase-admin"); // importa la libreria de firebase
firebase.initializeApp() // inicializa la app de firebase

const firestore = firebase.firestore() // Lo usamos para acceder a la base de datos
const auth = firebase.auth() // Lo usamos para acceder al nombre de los usuarios

const {
    // onDocumentWritten,
    onDocumentCreated,
    onDocumentUpdated,
    // onDocumentDeleted,
    // Change,
    // FirestoreEvent
} = require("firebase-functions/v2/firestore"); // importa las funciones de firestore

// const { onSchedule } = require("firebase-functions/v2/scheduler"); // No funciona por algún motivo, configurado a mano en https://console.cloud.google.com/cloudscheduler

const { onRequest } = require("firebase-functions/v2/https");

const {
    log,
    error,
  } = require("firebase-functions/logger");


async function sendNotificationToUser(userId, notification) {
    const tokenDocs = await firestore.collection("fcm_tokens").where("user_id", "==", userId).get() //busco en la coleccion fcm_tokens el token del usuario
    const tokens = tokenDocs.docs.map(doc => doc.id) //lo vuelvo un array de strings (el id del documento es el token)

    log(`Notificación enviada`, notification); //muestra en la consola de firebase el mensaje

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
        } catch (e) {
            error(`Error al enviar notificación`, e); //muestra en la consola de firebase el mensaje
            await firebase.firestore().collection("fcm_tokens").doc(token).delete()
        }
    }
}

module.exports.listCreated = onDocumentCreated('task_lists/{id}', async (event) => {
    const data = event.data.data() //event es lo que paso "crear una lista", .data es el documento y .data() es el contenido del documento
    const users = data.users

    const deadline = data.global_deadline

    // Como `print` pero para la cloud function (para debuggear)
    log(`Lista creada: ${data.name}, usuarios: ${users}, deadline ${deadline}`); //muestra en la consola de firebase el mensaje

    for (const user of users) { //recorre los usuarios con los que esta compartido
        await sendNotificationToUser(user, {
            "title": `Nueva lista: ${data.name}`,
            "body": deadline ? `Fecha límite: ${(new Date(deadline)).toLocaleDateString()}` : "Sin fecha límite"
        })
    }
});

module.exports.listCreated = onDocumentUpdated('task_lists/{id}', async (event) => {
    const previousUsers = event.data.before.data().users

    const data = event.data.after.data()
    // Hacemos un set con los usuarios actuales
    const newUsersSet = new Set(data.users)

    // Eliminamos del set los usuarios anteriores y nos quedan solo los que se agregaron
    for (const user of previousUsers) {
        newUsersSet.delete(user)
    }

    // Si no se agregó ningún usuario no hacemos nada
    if (newUsersSet.size === 0) return

    // Hacemos un array en base al set
    const users = Array.from(newUsersSet)

    const deadline = data.global_deadline

    // Como `print` pero para la cloud function (para debuggear)
    log(`Lista creada: ${data.name}, usuarios: ${users}, deadline ${deadline}`); //muestra en la consola de firebase el mensaje

    for (const user of users) { //recorre los usuarios con los que esta compartido
        await sendNotificationToUser(user, {
            "title": `Lista compartida: ${data.name}`,
            "body": deadline ? `Fecha límite: ${(new Date(deadline)).toLocaleDateString()}` : "Sin fecha límite"
        })
    }
});

module.exports.listTaskCreated = onDocumentCreated('task_lists/{id}/tasks/{taskId}', async (event) => {
    const data = event.data.data()

    // Como `print` pero para la cloud function (para debuggear)
    log(`Tarea creada: ${JSON.stringify(data)}`);

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

    const eventIsTaskCompleted = !before.completed && after.completed
    const eventIsTaskAssignedToUser = !before.assigned_user && after.assigned_user

    const id = event.params.id
    const taskList = (await firestore.collection("task_lists").doc(id).get()).data()

    // Como `print` pero para la cloud function (para debuggear)
    log(`Tarea completada: ${JSON.stringify(after)} --> ${JSON.stringify(after.title)}`);

    if (eventIsTaskCompleted) {
        const users = taskList.users

        for (const user of users) {
            if (user === after.completed_by) continue

            const userData = await auth.getUser(after.completed_by)

            await sendNotificationToUser(user, {
                "title": `Tarea completada ${after.title} - ${taskList.name}`,
                "body": `Completada por ${userData.displayName}`
            })
        }
    }

    if (eventIsTaskAssignedToUser) {
        const user = after.assigned_user

        const deadline = after.deadline

        await sendNotificationToUser(user, {
            "title": `Se te asignó una tarea: ${after.title} - ${taskList.name}`,
            "body": deadline ? `Fecha límite: ${(new Date(deadline)).toLocaleDateString()}` : "Sin fecha límite"
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

function getPreviousDayDate(date) {
    const day = date.getDate()
    const month = date.getMonth()
    const year = date.getFullYear()
    const previousDay = new Date(year, month, day - 1);
    return previousDay
}

async function getTaskListWithDeadLineAtDaysFromNow(days) {
    const date = getDateFromDaysFromNow(days)
    const taskLists = await firestore.collection("task_lists").where('deadline', '<=', date).where('deadline', '>', getPreviousDayDate(date)).get()
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


// No funciona, configurado a mano en https://console.cloud.google.com/cloudscheduler

// exports.sendNotification3DaysTaskList = onSchedule('every day 12:00', async (context) => {
//     const tasklists = await getTaskListWithDeadLineAtDaysFromNow(3)
//     await sendAlertToTaskLists(tasklists)
// })

// exports.sendNotification1DaysTaskList = onSchedule('every day 12:00', async (context) => {
//     const tasklists = await getTaskListWithDeadLineAtDaysFromNow(1)
//     await sendAlertToTaskLists(tasklists)
// })


async function getTasksWithDeadLineAtDaysFromNow(days) {
    const date = getDateFromDaysFromNow(days)
    const tasks = await firestore.collectionGroup("tasks").where('deadline', '<=', date).where('deadline', '>', getPreviousDayDate(date)).get()
    return tasks.docs
}

async function sendAlertToTasks(tasks) {
    for (const task of tasks) {
        const data = task.data()

        if (data.completed) return
        const taskList = (await task.ref.parent.parent.get()).data()

        const users = taskList.users

        for (const user of users) {
            await sendNotificationToUser(user, {
                "title": `${data.title} - ${taskList.name}`,
                "body": `Vence el ${data.deadline.toDate().toLocaleDateString()}`
            })
        }
    }
}


// No funciona, configurado a mano en https://console.cloud.google.com/cloudscheduler

// exports.sendNotification3DaysTask = onSchedule('every day 12:00', async (context) => {
//     const tasks = await getTasksWithDeadLineAtDaysFromNow(3)
//     await sendAlertToTasks(tasks)
// })

// exports.sendNotification1DaysTask = onSchedule('every day 12:00', async (context) => {
//     const tasks = await getTasksWithDeadLineAtDaysFromNow(1)
//     await sendAlertToTasks(tasks)
// })

exports.send_daily_notifications = onRequest(async (req, res) => {
    try {
        const tasklists1 = await getTaskListWithDeadLineAtDaysFromNow(3)
        await sendAlertToTaskLists(tasklists1)

        const tasklists2 = await getTaskListWithDeadLineAtDaysFromNow(1)
        await sendAlertToTaskLists(tasklists2)

        const tasks1 = await getTasksWithDeadLineAtDaysFromNow(3)
        await sendAlertToTasks(tasks1)

        const tasks2 = await getTasksWithDeadLineAtDaysFromNow(1)
        await sendAlertToTasks(tasks2)

        res.json({
            tasklists1,
            tasklists2,
            tasks1,
            tasks2
        })
    } catch (e) {
        console.error(e)
        res.json(e)
    }
})