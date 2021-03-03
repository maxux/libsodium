module libsodium

const (
	sign_len = 64
)

pub struct SigningKey {
	secret_key [secret_key_size]byte
pub:
	verify_key VerifyKey
}

pub struct VerifyKey {
pub:
	public_key [public_key_size]byte
}

pub fn new_signing_key(public_key [public_key_size]byte, secret_key [secret_key_size]byte) SigningKey {
	res := SigningKey{
		verify_key: {
			public_key: public_key
		}
		secret_key: secret_key
	}
	//res.secret_key = secret_key
	return res
}

pub fn generate_signing_key() SigningKey {
	res := SigningKey{}
	C.crypto_sign_keypair(res.verify_key.public_key, res.secret_key)
	return res
}

pub fn generate_signing_key_seed(seed &byte) SigningKey {
	res := SigningKey{}
	C.crypto_sign_seed_keypair(res.verify_key.public_key, res.secret_key, seed)
	return res
}


pub fn (key VerifyKey) verify_string(s string) bool {
	len := s.len - sign_len
	buf := []byte{len: len}
	mut buf_len := 0
	if C.crypto_sign_open(buf.data, &buf_len, s.str, s.len, key.public_key) != 0 {
		return false
	}
	return true
}

pub fn (key SigningKey) sign_string(s string) string {
	buf_size := sign_len + s.len
	mut buf := unsafe { vcalloc(buf_size) }
	mut buf_len := 0
	C.crypto_sign(buf, &buf_len, s.str, s.len, key.secret_key)
	return unsafe { buf.vstring_with_len(buf_len) }
}

pub fn (key VerifyKey) verify(b []byte) bool {
	len := b.len - sign_len
	buf := []byte{len: len}
	mut buf_len := 0
	if C.crypto_sign_open(buf.data, &buf_len, b.data, b.len, key.public_key) != 0 {
		return false
	}
	return true
}

pub fn (key SigningKey) sign(b []byte) []byte {
	buf := []byte{len: sign_len + b.len}
	mut buf_len := 0
	C.crypto_sign(buf.data, &buf_len, b.data, b.len, key.secret_key)
	return buf
}
