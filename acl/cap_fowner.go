package main

// This program demonstrats how to set CAP_FOWNER as ambient capability for 
// calling the `setfacl` program to set file ACL even the user running this
// program is neither root nor the owner of the file.
//
// The authorisation of setfacl is then "taken over" by the logic of this program.
//
// ```
// $ go build cap_fowner cap_fowner.go
//
// $ cp cap_fowner /tmp
//
// $ sudo setfcap cap_fowner+eip /tmp/cap_fowner
//
// $ /tmp/cap_fowner /usr/bin/setfacl -m ...
// ```

import (
	"syscall"
	"log"
	"os"
	"os/exec"
	"os/user"
	"fmt"
	"strings"
	"unsafe"
)

const CAP_FOWNER = 3

type capHeader struct {
	version uint32
	pid     int
}

type capData struct {
	effective   uint32
	permitted   uint32
	inheritable uint32
}

type caps struct {
	hdr  capHeader
	data [2]capData
}

func getCaps() (caps, error) {
	var c caps

	// Get capability version
	if _, _, errno := syscall.Syscall(syscall.SYS_CAPGET, uintptr(unsafe.Pointer(&c.hdr)), uintptr(unsafe.Pointer(nil)), 0); errno != 0 {
		return c, fmt.Errorf("SYS_CAPGET: %v", errno)
	}

	// Get current capabilities
	if _, _, errno := syscall.Syscall(syscall.SYS_CAPGET, uintptr(unsafe.Pointer(&c.hdr)), uintptr(unsafe.Pointer(&c.data[0])), 0); errno != 0 {
		return c, fmt.Errorf("SYS_CAPGET: %v", errno)
	}

	return c, nil
}

func mustSupportAmbientCaps() {
	var uname syscall.Utsname
	if err := syscall.Uname(&uname); err != nil {
		log.Fatalf("Uname: %v", err)
	}
	var buf [65]byte
	for i, b := range uname.Release {
		buf[i] = byte(b)
	}
	ver := string(buf[:])
	if i := strings.Index(ver, "\x00"); i != -1 {
		ver = ver[:i]
	}
	if strings.HasPrefix(ver, "2.") ||
		strings.HasPrefix(ver, "3.") ||
		strings.HasPrefix(ver, "4.1.") ||
		strings.HasPrefix(ver, "4.2.") {
		log.Fatalf("kernel version %q predates required 4.3; skipping test", ver)
	}
}

func isManager(user *user.User) bool {
	return user.Username == "honlee"
}

func main() {

	//mustSupportAmbientCaps()

	if len(os.Args) == 1 {
		log.Printf("Usage: %s <program> <arg1> <arg2> ...", os.Args[0])
		os.Exit(0)
	}

	caps, err := getCaps()
	if err != nil {
		log.Fatal(err)
	}

	// check role of the given user
	me, err := user.Current()
	if err != nil {
		log.Fatal(err)
	}

	if  ! isManager(me) {
		log.Fatalf("user not a manager: %s\n", me.Username)
	}

	// add CAP_FOWNER capability to the permitted and inheritable capability mask.
	caps.data[0].permitted |= 1 << uint(CAP_FOWNER)
	caps.data[0].inheritable |= 1 << uint(CAP_FOWNER)
        
	if _, _, errno := syscall.Syscall(syscall.SYS_CAPSET, uintptr(unsafe.Pointer(&caps.hdr)), uintptr(unsafe.Pointer(&caps.data[0])), 0); errno != 0 {
		log.Fatalf("SYS_CAPSET: %v", errno)
	}
	

	// try running the setfacl on a file the current user is not the owner
	cmd := exec.Command(os.Args[1], os.Args[2:]...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.SysProcAttr = &syscall.SysProcAttr{
		AmbientCaps: []uintptr{CAP_FOWNER},
	}
	if err := cmd.Run(); err != nil {
		log.Fatal(err)
	}
	log.Println("success!!")
}
