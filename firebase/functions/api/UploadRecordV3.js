// TODO: 녹음파일을 업로드하는 API입니다.
// Stroage에 파일을 저장하고, 해당 URL을 rooms/{RoomID}/records 컬렉션에 저장합니다.

const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');
const { v4: uuidv4 } = require('uuid');
const { FieldValue } = require('firebase-admin/firestore');
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fileParser = require('express-multipart-file-parser');

const app = express();
app.use(fileParser);
app.use(cors({ origin: true }));
app.use(bodyParser.urlencoded({ extended: true }));

const storage = admin.storage();
const bucket = storage.bucket();

app.post('/v3-uploadRecording', async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Only POST requests are accepted' });
  }

  const { roomNumber, userId } = req.query;
  if (!roomNumber || !userId) {
    return res.status(400).json({ error: 'roomNumber and userId are required' });
  }

  const file = req.files[0];
  if (!file) {
    return res.status(400).json({ error: 'File is required' });
  }

  console.log('Received file:', file);

  try {
    const uuid = uuidv4();
    const fileName = `audios/${uuid}_${file.originalname}`;
    const gcsFile = bucket.file(fileName);

    await gcsFile.save(file.buffer, {
      resumable: false,
      gzip: true,
      metadata: {
        contentType: file.mimetype,
      },
    });

    const [signedUrl] = await gcsFile.getSignedUrl({
      action: 'read',
      expires: Date.now() + 7 * 24 * 60 * 60 * 1000,
    });

    const roomRef = admin.firestore().collection('rooms').doc(roomNumber);

    console.time('FirestoreTransactionTime');
    await admin.firestore().runTransaction(async (transaction) => {
      const roomSnapshot = await transaction.get(roomRef);
      if (!roomSnapshot.exists) {
        throw new Error('Room does not exist');
      }

      const roomData = roomSnapshot.data();
      // 플레이어가 방 안에 있는지 체크
      const playerExists = roomData.players.some((player) => player.id === userId);
      if (!playerExists) {
        throw new Error('User not in the room');
      }
      // player 객체 가져오기
      const userData = roomData.players.find((player) => player.id === userId);
      if (!userData) {
        throw new Error('User not found');
      }

      // 현재 라운드 정보
      const currentRound = roomData.round || 0;
      const currentOrderRecord = roomData.recordOrder || 0;
      const currentMode = roomData.mode;
      const playersCount = roomData.players.length;

      // 현재 라운드에 해당하는 기존 기록
      const currentRoundRecords = roomData.records
        ? roomData.records.filter((r) => r.recordOrder === currentOrderRecord)
        : [];

      console.log('-------------------------------------');
      console.log(`현재 라운드: ${currentRound}`);
      console.log(`현재 라운드 녹음 수: ${currentRoundRecords.length}`);
      console.log(`플레이어 수: ${playersCount}`);
      console.log(`현재 모드: ${currentMode}`);
      console.log(`현재 OrderRecord: ${currentOrderRecord}`);
      console.log('-------------------------------------');

      switch (currentMode) {
        case 'humming': {
          const currentTime = new Date();
          const dueTime = new Date(currentTime.getTime() + 1 * 60 * 1000);

          // 이미 제출했는지 체크
          const hasSubmitted = currentRoundRecords.some((rec) => rec.player.id === userId);
          if (hasSubmitted) {
            throw new Error('User has already submitted');
          }

          // 녹음 데이터
          const recordData = {
            player: userData,
            recordOrder: currentOrderRecord,
            fileUrl: signedUrl,
          };

          // Firestore에 records 배열 업데이트
          transaction.update(roomRef, {
            records: FieldValue.arrayUnion(recordData),
          });

          // 모든 사용자가 제출을 마쳤다면 상태 갱신
          if (currentRoundRecords.length + 1 === playersCount) {
            transaction.update(roomRef, {
              recordOrder: currentOrderRecord + 1,
              status: 'rehumming',
              dueTime: dueTime,
            });
          }
          break;
        }
        default:
          throw new Error('Invalid mode');
      }
    });
    return res.status(200).send({ success: true });
  } catch (error) {
    console.error('Error during file upload or Firestore transaction:', error);
    return res.status(500).json({ error: error.message });
  }
});

// Cloud Function 내보내기
module.exports.uploadRecordingV3 = onRequest({ region: 'asia-southeast1' }, app);
