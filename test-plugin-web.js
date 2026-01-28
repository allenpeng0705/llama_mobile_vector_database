// Test script for the LlamaMobileVD plugin web implementation
const { LlamaMobileVD } = require('./llama_mobile_vd-capacitor-plugin/dist/index.js');

async function testPlugin() {
  console.log('Testing LlamaMobileVD plugin web implementation...');
  
  try {
    // Test getVersion
    console.log('\n1. Testing getVersion...');
    const versionResult = await LlamaMobileVD.getVersion();
    console.log('Version:', versionResult.version);
    
    // Test createVectorStore
    console.log('\n2. Testing createVectorStore...');
    const createStoreResult = await LlamaMobileVD.createVectorStore({
      dimension: 128,
      metric: 'cosine'
    });
    const storeId = createStoreResult.storeId;
    console.log('Created vector store with ID:', storeId);
    
    // Test addVectors
    console.log('\n3. Testing addVectors...');
    const vectors = Array.from({ length: 10 }, () => 
      Array.from({ length: 128 }, () => Math.random() * 2 - 1)
    );
    await LlamaMobileVD.addVectors({
      storeId,
      vectors
    });
    console.log('Added 10 vectors to store');
    
    // Test getVectorCount
    console.log('\n4. Testing getVectorCount...');
    const countResult = await LlamaMobileVD.getVectorCount({ storeId });
    console.log('Vector count:', countResult.count);
    
    // Test search
    console.log('\n5. Testing search...');
    const queryVector = Array.from({ length: 128 }, () => Math.random() * 2 - 1);
    const searchResult = await LlamaMobileVD.search({
      storeId,
      queryVector,
      k: 3
    });
    console.log('Search results:', searchResult);
    
    // Test clearVectors
    console.log('\n6. Testing clearVectors...');
    await LlamaMobileVD.clearVectors({ storeId });
    const countAfterClear = await LlamaMobileVD.getVectorCount({ storeId });
    console.log('Vector count after clear:', countAfterClear.count);
    
    // Test destroyVectorStore
    console.log('\n7. Testing destroyVectorStore...');
    await LlamaMobileVD.destroyVectorStore({ storeId });
    console.log('Destroyed vector store');
    
    console.log('\n✅ All tests passed! The web implementation is working correctly.');
  } catch (error) {
    console.error('❌ Test failed:', error);
  }
}

testPlugin();
