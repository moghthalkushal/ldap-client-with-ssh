FROM ubuntu
USER root
RUN chmod 777 -R /home
RUN apt-get update -y --fix-missing
ENV LDAP_SEREVER 172.17.0.2
#172.17.0.2
ENV LDAP_BASE_DN dc=jc,dc=be
#dc=jc,dc=be
RUN apt-get install -y vim
RUN mkdir /var/run/sshd
#----------------------------------------------------------
#--- SSH
#----------------------------------------------------------
RUN apt-get install -y sudo passwd openssh-server
RUN echo 'root:root' |chpasswd && adduser root sudo
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#PubkeyAuthentication\s+.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#PasswordAuthentication\s+.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#UsePAM\s+.*/UsePAM yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#UseLogin\s+.*/UseLogin yes/' /etc/ssh/sshd_config
#RUN mkdir -p /var/run/sshd

#----------------------------------------------------------
#--- LDAP
#----------------------------------------------------------
RUN DEBIAN_FRONTEND=noninteractive apt-get install -qq libnss-ldap libpam-ldap ldap-utils nscd
#ADD ldap-auth-config /etc/auth-client-config/profile.d/ldap-auth-config
RUN echo "base $LDAP_BASE_DN"                   > /etc/ldap.conf ;\
    echo "uri ldap://$LDAP_SEREVER/"           >> /etc/ldap.conf ;\
    echo "ldap_version 3"                      >> /etc/ldap.conf ;\
    echo "rootbinddn cn=admin,$LDAP_BASE_DN" >> /etc/ldap.conf ;\
    echo "pam_password md5"                    >> /etc/ldap.conf    
RUN echo "session required pam_mkhomedir.so skel=/etc/skel umask=0077"   >> /etc/pam.d/common-auth

RUN sed -i 's/\(passwd:.*$\)/\1 ldap/' /etc/nsswitch.conf
RUN sed -i 's/\(group:.*$\)/\1 ldap/' /etc/nsswitch.conf
RUN sed -i 's/\(shadow:.*$\)/\1 ldap/' /etc/nsswitch.conf
RUN sed -i 's/\(netgroup\)/\1 #/' /etc/nsswitch.conf
RUN echo "netgroup:       ldap" >>/etc/nsswitch.conf

RUN service nscd restart
EXPOSE 22

CMD    ["/usr/sbin/sshd", "-D"]
