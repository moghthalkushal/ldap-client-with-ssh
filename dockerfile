FROM ubuntu
USER root

# SET ENVIRONMENT VARIABLES FOR CONFIG SETTINGS
ENV LDAP_BASE_DN=$LDAP_BASE_DN
ENV LDAP_SEREVER=$LDAP_SEREVER

# GENERIC TOOLS AND UPDATES
RUN chmod 777 -R /home
RUN apt-get update -y --fix-missing
RUN apt-get install -y vim


# SSH INSTALLATION
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN mkdir /root/.ssh
RUN echo 'root:root' |chpasswd && adduser root sudo
RUN echo "X11UseLocalhost no" >> /etc/ssh/sshd_config
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM yes/UsePAM yes/g' /etc/ssh/sshd_config
EXPOSE 22

# LDAP CLIENT INSTALLATION
RUN DEBIAN_FRONTEND=noninteractive apt-get install -qq libnss-ldap libpam-ldap ldap-utils nscd

# LDAP-CLIENT SSH SETTINGS
RUN sed -ri 's/^#PubkeyAuthentication\s+.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#PasswordAuthentication\s+.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#UseLogin\s+.*/UseLogin yes/' /etc/ssh/sshd_config

# LDAP CLIENT CONFIGURATION

RUN echo "base $LDAP_BASE_DN"              >> /etc/ldap.conf 
RUN echo "uri ldap://$LDAP_SEREVER/"           >> /etc/ldap.conf 
RUN echo "ldap_version 3"                      >> /etc/ldap.conf 
RUN echo "rootbinddn cn=manager,$LDAP_BASE_DN" >> /etc/ldap.conf 
RUN echo "pam_password md5"                    >> /etc/ldap.conf    
RUN echo "session required pam_mkhomedir.so skel=/etc/skel umask=0077"   >> /etc/pam.d/common-auth

RUN sed -i 's/\(passwd:.*$\)/\1 ldap/' /etc/nsswitch.conf
RUN sed -i 's/\(group:.*$\)/\1 ldap/' /etc/nsswitch.conf
RUN sed -i 's/\(shadow:.*$\)/\1 ldap/' /etc/nsswitch.conf
RUN sed -i 's/\(netgroup\)/\ #/' /etc/nsswitch.conf
RUN echo "netgroup:       ldap" >>/etc/nsswitch.conf

ENTRYPOINT ["entry-point-ldap-config.sh"]
