# MembershipBoard Gas Analysis Report

### 1. Storage cost comparison：針對加入 1000 名會員，成本分析比較如下：
(a) addMember*1000 的 Gas 消耗為 (37,981+21,000)*1000=58,981,000
(b) batchAddMembers 的 Gas 消耗為 24,913,808+21,000=24,934,808
(c) setMerkleRoot 的 Gas 消耗為 45,339+21,000=66,339

為何 setMerkleRoot 消耗 Gas 最少？因為區塊鏈操作為 SSTORE，使用 Mapping 需要將 1000 人地址分別存入，MerkleTree 只需要寫入 1 個 32bytes 的 Root，因此不論名單內有多少人，合約占用的空間不變。

**Gas Profiling Results：**


| Action | 合約運算 Gas | 基礎手續費 (Base Gas) | 總計 Gas 消耗 |
| :--- | :--- | :--- | :--- |
| addMember | 37,981 | 21,000 | 58,981 |
| addMember x1000 | 37,981,000 | 21,000,000 | 58,981,000 |
| batchAddMembers(1000 人) | 34,103,023 | 21,000 | 34,124,023 |
| setMerkleRoot | 45,339 | 21,000 | 66,339 |
| verifyMemberByMapping | 2,891 | 0 | 2,891 |
| verifyMemberByProof | 5,658 | 0 | 5,658 |


---

### 2. Verification Cost Comparison：驗證單一會員消耗 Gas，比較如下：
(a) Mapping：2,891 Gas
(b) Merkle Proof：5,658 Gas

Mapping 驗證較便宜，因為只是查詢資料庫，Merkle Proof 需要在合約內進行多次 keccak256，運算越多次，消耗的 Gas 就越多。

---

### 3. Trade-off analysis：
**(a) 選擇 Mapping：**
i) 如果合約是 owner 再逐一審核並主動加入成員，成員不需付費，這種情況會選擇 Mapping。
ii) 如果成員名單經常變動，Mapping 只需單次增加，但 MerkleTree 每次都要重新計算 Root。
iii) 但是論隱私，因為 Mapping 儲存在鏈上所有人都可以知道合約內的成員有誰。

**(b) 選擇 MerkleTree：**
i) 若 Owner 需要儲存大量名單時，只需要在鏈下算出 Root，然後呼叫一次 setMerkleRoot 即可。
ii) 若名單在活動開始後就不再變動，Merkle Tree 的效率最高。
iii) 鏈上只存一個 Root，使用者驗證時，也只需揭露自己的 Proof。

---

### 4. Batch Size Experimentation：我嘗試批次 50、100、250、500 規模，觀察平均每位會員 Gas 變化：


| Batch Size | 測試回報 Gas | 總 Gas (運算+21k) | 每位成員平均 Gas | 節省率 (相較於 50 人) |
| :--- | :--- | :--- | :--- | :--- |
| 50 人 | 1,311,977 | 1,332,977 | 26,659 | |
| 100 人 | 2,596,267 | 2,617,267 | 26,172 | 1.8% |
| 250 人 | 6,449,438 | 6,470,438 | 25,881 | 2.9% |
| 500 人 | 12,872,211 | 12,893,211 | 25,786 | 3.3% |


(a). 為何每位成員平均 Gas 隨著批量增加而減少?因為 21,000 Gas 手續費是被平均分攤。
(b). Sweet Spot：建議範圍 250-500 人，在這個區間每位成員平均 Gas 已經降到最低點。
