import { createClient } from '@supabase/supabase-js'
import { decryptData } from '$lib/services/crypto'

// import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public'
// import { testEncryptionDecryption } from '$lib/encryption.ts'
console.log("SUPABASE_URL_ENCRYPTED__", __SUPABASE_URL_ENCRYPTED__);
console.log("SUPABASE_URL_ENCRYPTION_KEY__", __SUPABASE_URL_ENCRYPTION_KEY__);
console.log("SUPABASE_ANON_KEY_ENCRYPTED__", __SUPABASE_ANON_KEY_ENCRYPTED__);
console.log("SUPABASE_ANON_KEY_ENCRYPTION_KEY__", __SUPABASE_ANON_KEY_ENCRYPTION_KEY__);
export const supabase = createClient(
    decryptData(__SUPABASE_URL_ENCRYPTED__, __SUPABASE_URL_ENCRYPTION_KEY__),
    decryptData(__SUPABASE_ANON_KEY_ENCRYPTED__, __SUPABASE_ANON_KEY_ENCRYPTION_KEY__)
)
