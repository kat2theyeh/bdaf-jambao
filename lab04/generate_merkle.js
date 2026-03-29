const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require("fs");

// 1. 讀取剛才生成的 1,000 個地址
const data = JSON.parse(fs.readFileSync("members.json", "utf8"));

// 2. 將地址轉換為 OpenZeppelin 要求的格式：[[addr1], [addr2], ...]
const values = data.addresses.map(addr => [addr]);

// 3. 建立 Merkle Tree (編碼格式為 "address")
const tree = StandardMerkleTree.of(values, ["address"]);

// 4. 印出你要填入測試 (Test) 的關鍵數值
console.log("-----------------------------------------");
console.log("給 setMerkleRoot 使用的 Root:");
console.log(tree.root); 
console.log("-----------------------------------------");

// 5. 取得第 0 個地址的 Proof 來測試驗證功能
const index = 0;
const proof = tree.getProof(index);
console.log("測試用地址 (Member 0):", data.addresses[index]);
console.log("給 verifyMemberByProof 使用的 Proof:");
console.log(JSON.stringify(proof));
console.log("-----------------------------------------");

// 6. 儲存完整樹資料供後續使用
fs.writeFileSync("tree.json", JSON.stringify(tree.dump()));
